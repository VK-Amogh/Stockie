import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../utils/pricing_calculator.dart';

class InventoryService extends ChangeNotifier {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal() {
    loadData();
  }

  final List<Product> _products = [];
  final List<Invoice> _invoices = [];
  List<Product> get products => List.unmodifiable(_products);
  List<Invoice> get invoices => List.unmodifiable(_invoices);

  Future<void> addProduct(Product product) async {
    // Always add as a new entry (batch) unless exact match on all fields
    // Actually, for "Add Product" screen, we want to create a new batch if price/mrp/expiry differs.
    // If everything is same, we update quantity.

    int index = _products.indexWhere(
      (p) =>
          p.name.toLowerCase() == product.name.toLowerCase() &&
          p.category.toLowerCase() == product.category.toLowerCase() &&
          p.buyPrice == product.buyPrice &&
          p.mrp == product.mrp &&
          p.expiryDate == product.expiryDate,
    );

    if (index != -1) {
      // Update quantity if exact match exists
      _products[index].quantity += product.quantity;
    } else {
      // Add new product batch
      _products.add(product);
    }
    notifyListeners();
    await saveData();
  }

  // Helpers for UI
  int get totalProductsCount => _products.length;

  int get lowStockCount =>
      _products.where((p) => p.quantity > 0 && p.quantity <= 10).length;

  int get outOfStockCount => _products.where((p) => p.quantity <= 0).length;

  // Group products by name
  Map<String, List<Product>> getProductsGroupedByName() {
    Map<String, List<Product>> grouped = {};
    for (var product in _products) {
      if (!grouped.containsKey(product.name)) {
        grouped[product.name] = [];
      }
      grouped[product.name]!.add(product);
    }
    return grouped;
  }

  // Get all variants (batches) for a specific product name
  List<Product> getProductVariants(String productName) {
    return _products
        .where((p) => p.name.toLowerCase() == productName.toLowerCase())
        .toList();
  }

  // Calculate total quantity for a grouped product
  double getTotalQuantity(String productName) {
    return getProductVariants(
      productName,
    ).fold(0.0, (sum, item) => sum + item.quantity);
  }

  Future<void> recordSale(
    Map<Product, double> cart,
    String customerType,
  ) async {
    List<InvoiceItem> invoiceItems = [];
    double totalAmount = 0;

    cart.forEach((product, quantity) {
      // Find the specific batch instance
      int index = _products.indexOf(product);
      if (index != -1) {
        _products[index].quantity -= quantity;
        // Optional: Remove batch if quantity becomes 0?
      }
      PricingResult result = product.calculateTransaction(quantity);
      double itemTotal = result.sellPrice;

      // Calculate Unit Buy Price (Effective)
      // We use result.costPrice (Total Cost) / quantity to get effective unit buy price
      // This ensures (price - buyPrice) * quantity matches result.profit
      double unitBuyPrice = quantity > 0 ? result.costPrice / quantity : 0;

      invoiceItems.add(
        InvoiceItem(
          productName: product.name,
          quantity: quantity,
          price: quantity > 0
              ? itemTotal / quantity
              : 0, // Effective unit price
          buyPrice: unitBuyPrice,
          expiryDate: product.expiryDate,
          unit: product.unit,
          packSize: product.packSize,
        ),
      );
      totalAmount += itemTotal;
    });

    final invoice = Invoice(
      id: 'S-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      date: DateTime.now(),
      type: InvoiceType.sale,
      items: invoiceItems,
      totalAmount: totalAmount,
      customerName: customerType,
    );
    _invoices.add(invoice);
    notifyListeners();
    await saveData();
  }

  Future<void> recordPurchase(
    Product product,
    double quantity,
    double totalCost,
  ) async {
    final invoice = Invoice(
      id: 'P-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      date: DateTime.now(),
      type: InvoiceType.purchase,
      items: [
        InvoiceItem(
          productName: product.name,
          quantity: quantity,
          price: product.buyPrice,
          buyPrice: product.buyPrice,
          expiryDate: product.expiryDate,
          unit: product.unit,
          packSize: product.packSize,
        ),
      ],
      totalAmount: totalCost,
    );
    _invoices.add(invoice);
    notifyListeners();
    await saveData();
  }

  double getTodaysSales() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _invoices
        .where(
          (i) =>
              i.type == InvoiceType.sale &&
              i.date.isAfter(today) &&
              i.date.isBefore(today.add(const Duration(days: 1))),
        )
        .fold(0.0, (sum, i) => sum + i.totalAmount);
  }

  double getTodaysProfit() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    double totalProfit = _invoices
        .where(
          (i) =>
              i.type == InvoiceType.sale &&
              i.date.isAfter(today) &&
              i.date.isBefore(today.add(const Duration(days: 1))),
        )
        .expand((i) => i.items)
        .fold(0.0, (sum, item) {
          final double itemProfit =
              (item.price - item.buyPrice) * item.quantity;
          return sum + (itemProfit < 0 ? 0 : itemProfit);
        });

    return totalProfit;
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Get current user email to isolate data
    String? userString = prefs.getString('currentUser');
    if (userString == null) {
      // No user logged in, clear data
      _products.clear();
      _invoices.clear();
      notifyListeners();
      return;
    }

    final Map<String, dynamic> user = jsonDecode(userString);
    final String email = user['email'];
    final String productKey = 'products_$email';
    final String invoiceKey = 'invoices_$email';

    // Load Products
    final String? productsJson = prefs.getString(productKey);
    if (productsJson != null) {
      final List<dynamic> decoded = jsonDecode(productsJson);
      _products.clear();
      _products.addAll(decoded.map((e) => Product.fromJson(e)).toList());
    } else {
      _products.clear();
    }

    // Load Invoices
    final String? invoicesJson = prefs.getString(invoiceKey);
    if (invoicesJson != null) {
      final List<dynamic> decoded = jsonDecode(invoicesJson);
      _invoices.clear();
      _invoices.addAll(decoded.map((e) => Invoice.fromJson(e)).toList());
    } else {
      _invoices.clear();
    }
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Get current user email
    String? userString = prefs.getString('currentUser');
    if (userString == null) return; // Should not happen if logged in

    final Map<String, dynamic> user = jsonDecode(userString);
    final String email = user['email'];
    final String productKey = 'products_$email';
    final String invoiceKey = 'invoices_$email';

    // Save Products
    final String productsJson = jsonEncode(
      _products.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(productKey, productsJson);

    // Save Invoices
    final String invoicesJson = jsonEncode(
      _invoices.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(invoiceKey, invoicesJson);
  }

  Future<void> clearAllData() async {
    // This now clears specific user data if needed, or we can just clear memory
    // For safety, let's just clear memory.
    // Actual storage wipe should probably be a specific "Delete Account" feature.
    _products.clear();
    _invoices.clear();
    notifyListeners();
  }
}
