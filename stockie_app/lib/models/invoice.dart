import 'package:stockie_app/models/product.dart';

enum InvoiceType { sale, purchase }

class InvoiceItem {
  final String productName;
  final double quantity;
  final double price;
  final double buyPrice;
  final String expiryDate;
  final String unit;
  final double? packSize;

  InvoiceItem({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.buyPrice,
    required this.expiryDate,
    this.unit = '',
    this.packSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'buyPrice': buyPrice,
      'expiryDate': expiryDate,
      'unit': unit,
      'packSize': packSize,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      productName: json['productName'],
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      buyPrice: (json['buyPrice'] as num).toDouble(),
      expiryDate: json['expiryDate'],
      unit: json['unit'] ?? '',
      packSize: (json['packSize'] as num?)?.toDouble(),
    );
  }
}

class Invoice {
  final String id;
  final DateTime date;
  final InvoiceType type;
  final List<InvoiceItem> items;
  final double totalAmount;
  final String customerName; // For sales
  final String status; // Paid, Pending, etc.

  Invoice({
    required this.id,
    required this.date,
    required this.type,
    required this.items,
    required this.totalAmount,
    this.customerName = '',
    this.status = 'Paid',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'customerName': customerName,
      'status': status,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: InvoiceType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => InvoiceType.sale,
      ),
      items: (json['items'] as List)
          .map((i) => InvoiceItem.fromJson(i))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      customerName: json['customerName'] ?? '',
      status: json['status'] ?? 'Paid',
    );
  }
}
