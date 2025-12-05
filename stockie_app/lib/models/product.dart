import '../utils/pricing_calculator.dart';

class Product {
  final String name;
  final String category;
  final double buyPrice; // Total Cost of Pack (if packSize > 0) OR Unit Cost
  final double mrp; // Total MRP of Pack (if packSize > 0) OR Unit MRP
  final String expiryDate;
  double quantity;
  final String unit;
  final double? packSize;
  final double? sellingPricePerUnit; // Loose Selling Rate per Kg/Unit

  Product({
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.mrp,
    required this.expiryDate,
    required this.quantity,
    this.unit = '',
    this.packSize,
    this.sellingPricePerUnit,
  });

  PricingResult calculateTransaction(double qty) {
    double costPerKg = buyPrice;
    double mrpPerKg = mrp;

    return PricingCalculator.calculateTransaction(
      packetWeightKg: packSize ?? 0,
      costPerKg: costPerKg,
      sellingRatePerKg: sellingPricePerUnit ?? mrpPerKg,
      mrpPerKg: mrpPerKg,
      saleAmountRaw: qty.toString(),
    );
  }

  double calculatePrice(double qty) {
    return calculateTransaction(qty).sellPrice;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'buyPrice': buyPrice,
      'mrp': mrp,
      'expiryDate': expiryDate,
      'quantity': quantity,
      'unit': unit,
      'packSize': packSize,
      'sellingPricePerUnit': sellingPricePerUnit,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      category: json['category'],
      buyPrice: (json['buyPrice'] as num).toDouble(),
      mrp: (json['mrp'] as num).toDouble(),
      expiryDate: json['expiryDate'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      packSize: (json['packSize'] as num?)?.toDouble(),
      sellingPricePerUnit: (json['sellingPricePerUnit'] as num?)?.toDouble(),
    );
  }
}
