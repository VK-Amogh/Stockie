import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockie_app/theme/app_theme.dart';
import '../models/product.dart';
import '../services/inventory_service.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  String _customerType = 'Walk-in Customer';
  String _searchQuery = '';
  final Map<Product, double> _cart = {};
  final TextEditingController _searchController = TextEditingController();

  // Get unique product names that match the search query
  List<String> get _filteredProductNames {
    final allProducts = InventoryService().products;
    if (_searchQuery.isEmpty) return [];

    final matchingProducts = allProducts
        .where(
          (p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    // Return unique names
    return matchingProducts.map((p) => p.name).toSet().toList();
  }

  double get _subtotal {
    double total = 0;
    _cart.forEach((product, quantity) {
      total += product.calculatePrice(quantity);
    });
    return total;
  }

  void _handleProductSelection(String productName) {
    final variants = InventoryService().getProductVariants(productName);

    if (variants.isEmpty) return;

    if (variants.length == 1) {
      _addToCart(variants.first);
    } else {
      _showBatchSelectionDialog(variants);
    }
  }

  void _showBatchSelectionDialog(List<Product> variants) {
    // Sort by expiry
    variants.sort((a, b) {
      try {
        final partsA = a.expiryDate.split('/');
        final dateA = DateTime(
          int.parse(partsA[2]),
          int.parse(partsA[1]),
          int.parse(partsA[0]),
        );
        final partsB = b.expiryDate.split('/');
        final dateB = DateTime(
          int.parse(partsB[2]),
          int.parse(partsB[1]),
          int.parse(partsB[0]),
        );
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Batch for ${variants.first.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: variants.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final variant = variants[index];
                  final isOldest = index == 0;
                  final isNewest = index == variants.length - 1;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _addToCart(variant);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isOldest
                                  ? Colors.red.withOpacity(0.1)
                                  : (isNewest
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isOldest
                                  ? 'Old Stock'
                                  : (isNewest ? 'New Stock' : 'Stock'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isOldest
                                    ? Colors.red
                                    : (isNewest ? Colors.green : Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MRP: ₹${variant.mrp} | Buy: ₹${variant.buyPrice}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Qty: ${variant.quantity} | Exp: ${variant.expiryDate}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.add_circle_outline,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    setState(() {
      if (_cart.containsKey(product)) {
        if (_cart[product]! < product.quantity) {
          _cart[product] = _cart[product]! + 1.0;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not enough stock available')),
          );
        }
      } else {
        if (product.quantity > 0) {
          // Auto-set quantity to pack size if available, otherwise 1.0
          double initialQty =
              (product.packSize != null && product.packSize! > 0)
              ? product.packSize!
              : 1.0;

          if (initialQty <= product.quantity) {
            _cart[product] = initialQty;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Not enough stock available')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product is out of stock')),
          );
        }
      }
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      if (_cart.containsKey(product)) {
        if (_cart[product]! > 1.0) {
          _cart[product] = _cart[product]! - 1.0;
        } else {
          _cart.remove(product);
        }
      }
    });
  }

  void _incrementCartItem(Product product) {
    setState(() {
      if (_cart.containsKey(product)) {
        if (_cart[product]! < product.quantity) {
          _cart[product] = _cart[product]! + 1.0;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not enough stock available')),
          );
        }
      }
    });
  }

  void _updateCartItemQuantity(Product product, double quantity) {
    setState(() {
      if (quantity <= 0) {
        _cart.remove(product);
      } else if (quantity <= product.quantity) {
        _cart[product] = quantity;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough stock available')),
        );
      }
    });
  }

  void _showQuantityDialog(Product product) {
    final TextEditingController qtyController = TextEditingController();
    String selectedUnit = product.unit; // Default to product's base unit

    // Define compatible units based on product unit
    List<String> compatibleUnits = [product.unit];
    if (product.unit.toLowerCase() == 'kg') compatibleUnits.addAll(['g', 'mg']);
    if (product.unit.toLowerCase() == 'g') compatibleUnits.add('mg');
    if (product.unit.toLowerCase() == 'l') compatibleUnits.add('ml');

    double availableQty = product.quantity;
    String availableStockText = '$availableQty ${product.unit}';

    if (product.packSize != null && product.packSize! > 0) {
      int packs = (availableQty / product.packSize!).ceil();
      availableStockText += ' ($packs Packs)';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Enter Quantity',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Stock Info Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available: $availableStockText',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Input Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: qtyController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.0',
                              hintStyle: TextStyle(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedUnit,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                items: compatibleUnits
                                    .map(
                                      (unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(
                                          unit,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => selectedUnit = value!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          double enteredQty =
                              double.tryParse(qtyController.text) ?? 0.0;
                          if (enteredQty <= 0) return;

                          // Convert to base unit
                          double finalQty = enteredQty;
                          String baseUnit = product.unit.toLowerCase();
                          String selected = selectedUnit.toLowerCase();

                          if (baseUnit == 'kg') {
                            if (selected == 'g') finalQty = enteredQty / 1000;
                            if (selected == 'mg')
                              finalQty = enteredQty / 1000000;
                          } else if (baseUnit == 'g') {
                            if (selected == 'mg') finalQty = enteredQty / 1000;
                          } else if (baseUnit == 'l') {
                            if (selected == 'ml') finalQty = enteredQty / 1000;
                          }

                          _updateCartItemQuantity(product, finalQty);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Update',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Sale',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Customer Selection
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Walk-in Customer'),
                        onTap: () {
                          setState(() => _customerType = 'Walk-in Customer');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.business),
                        title: const Text('Business'),
                        onTap: () {
                          setState(() => _customerType = 'Business');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _customerType == 'Business'
                          ? Icons.business
                          : Icons.person,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _customerType,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    Icon(Icons.expand_more, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search or Scan Product',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: AppTheme.primary,
                    ),
                    onPressed: () {},
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),

          // Content Area (Cart or Search Results)
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildCartList(),
          ),

          // Footer
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Subtotal',
                    '₹${_subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Discount', '- ₹0.00'),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        '₹${_subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Implement Checkout Logic
                        // Update Inventory and Create Invoice
                        await InventoryService().recordSale(
                          _cart,
                          _customerType,
                        );

                        if (!context.mounted) return;

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sale completed successfully'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Complete Sale',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredProductNames;
    if (results.isEmpty) {
      return const Center(child: Text('No products found'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final productName = results[index];
        final totalQty = InventoryService().getTotalQuantity(productName);

        return ListTile(
          onTap: () => _handleProductSelection(productName),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: Colors.grey),
          ),
          title: Text(
            productName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Total Stock: $totalQty'),
          trailing: const Icon(Icons.add_circle, color: AppTheme.primary),
        );
      },
    );
  }

  Widget _buildCartList() {
    if (_cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for products to add them to the sale',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _cart.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = _cart.keys.elementAt(index);
        final quantity = _cart[product]!;
        return _buildSaleItem(product, quantity);
      },
    );
  }

  Widget _buildSaleItem(Product product, double quantity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: const Icon(Icons.inventory_2, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₹${product.calculatePrice(quantity).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildQtyButton(
                Icons.remove,
                onTap: () => _removeFromCart(product),
              ),
              InkWell(
                onTap: () => _showQuantityDialog(product),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${quantity.toStringAsFixed(3)} ${product.unit}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      if (product.packSize != null && product.packSize! > 0)
                        Text(
                          '${(quantity / product.packSize!).ceil()} Packs',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _buildQtyButton(
                Icons.add,
                isAdd: true,
                onTap: () => _incrementCartItem(product),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(
    IconData icon, {
    bool isAdd = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isAdd ? AppTheme.primary : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isAdd ? Colors.white : AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
