import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../services/inventory_service.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _categoryController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _quantityController = TextEditingController();
  final _packSizeController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  Product? _selectedProduct;
  double _grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _buyPriceController.addListener(_calculateTotal);
    _quantityController.addListener(_calculateTotal);
    _packSizeController.addListener(_calculateTotal);
    // Add listener to rebuild UI when pack size changes (for dynamic label)
    _packSizeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _expiryDateController.dispose();
    _buyPriceController.dispose();
    _mrpController.dispose();
    _quantityController.dispose();
    _packSizeController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_selectedProduct != null) {
      double count = double.tryParse(_quantityController.text) ?? 0.0;
      double packSize = double.tryParse(_packSizeController.text) ?? 1.0;
      double buyPrice = double.tryParse(_buyPriceController.text) ?? 0.0;

      if (_packSizeController.text.isEmpty) packSize = 1.0;

      setState(() {
        _grandTotal = count * packSize * buyPrice;
      });
    }
  }

  void _onProductSelected(Product product) {
    setState(() {
      _selectedProduct = product;
      _categoryController.text = product.category;
      _buyPriceController.text = product.buyPrice.toString();
      _mrpController.text = product.mrp.toString();
      _expiryDateController.text = product.expiryDate;
      if (product.packSize != null) {
        _packSizeController.text = product.packSize.toString();
      } else {
        _packSizeController.clear();
      }
      if (product.sellingPricePerUnit != null) {
        _sellingPriceController.text = product.sellingPricePerUnit.toString();
      } else {
        _sellingPriceController.clear();
      }
      _calculateTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventory = InventoryService();
    // Flatten all products for search (showing variants)
    final allProducts = inventory.products;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0D111C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Restock Inventory',
          style: TextStyle(
            color: Color(0xFF0D111C),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCED6E9)),
                    ),
                    child: Column(
                      children: [
                        // Product Search (Autocomplete)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Product to Restock',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D111C),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Autocomplete<Product>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<Product>.empty();
                                      }
                                      return allProducts.where((
                                        Product option,
                                      ) {
                                        return option.name
                                            .toLowerCase()
                                            .contains(
                                              textEditingValue.text
                                                  .toLowerCase(),
                                            );
                                      });
                                    },
                                displayStringForOption: (Product option) =>
                                    '${option.name} (MRP: ₹${option.mrp})',
                                onSelected: _onProductSelected,
                                fieldViewBuilder:
                                    (
                                      context,
                                      textEditingController,
                                      focusNode,
                                      onFieldSubmitted,
                                    ) {
                                      return TextField(
                                        controller: textEditingController,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Search existing product...',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF7F9FC),
                                          prefixIcon: const Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFCED6E9),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFCED6E9),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                            64, // Adjust width
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder:
                                              (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                final Product option = options
                                                    .elementAt(index);
                                                return ListTile(
                                                  title: Text(option.name),
                                                  subtitle: Text(
                                                    'MRP: ₹${option.mrp} | Buy: ₹${option.buyPrice} | Exp: ${option.expiryDate}',
                                                  ),
                                                  onTap: () {
                                                    onSelected(option);
                                                  },
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFCED6E9)),

                        // Buy Price & MRP (Read Only)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Buy Price (per Unit)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D111C),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _buyPriceController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      onChanged: (_) => _calculateTotal(),
                                      decoration: InputDecoration(
                                        prefixText: '₹ ',
                                        hintText: '0.00',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFCED6E9),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFCED6E9),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'MRP (per Unit)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D111C),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _mrpController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        prefixText: '₹ ',
                                        filled: true,
                                        fillColor: const Color(0xFFF0F2F5),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFCED6E9)),

                        // Selling Price (Loose)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _packSizeController.text.isNotEmpty &&
                                        (double.tryParse(
                                                  _packSizeController.text,
                                                ) ??
                                                0) >
                                            0
                                    ? 'Selling Price (per Unit/Loose)'
                                    : 'Selling Price per Unit (Optional)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D111C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _packSizeController.text.isNotEmpty &&
                                        (double.tryParse(
                                                  _packSizeController.text,
                                                ) ??
                                                0) >
                                            0
                                    ? 'Price for loose sales (e.g. per Kg/L/g)'
                                    : 'Price for loose sales (e.g. per Kg/L/g)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _sellingPriceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  prefixText: '₹ ',
                                  hintText: 'Enter price per unit',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF7F9FC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCED6E9),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCED6E9),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFCED6E9)),

                        // Expiry Date (Read Only)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Expiry Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D111C),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _expiryDateController,
                                decoration: InputDecoration(
                                  hintText: 'DD/MM/YYYY',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCED6E9),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCED6E9),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Link to Add New Product
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add_product');
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF36C1A2),
                      ),
                      label: const Text(
                        'Create New Product / Batch',
                        style: TextStyle(
                          color: Color(0xFF36C1A2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF36C1A2,
                        ).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F9FC),
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Cost',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D111C),
                        ),
                      ),
                      Text(
                        '₹${_grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF0D111C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedProduct == null
                          ? null
                          : () async {
                              double count =
                                  double.tryParse(_quantityController.text) ??
                                  0.0;
                              double packSize =
                                  double.tryParse(_packSizeController.text) ??
                                  1.0;
                              double totalQty = count * packSize;

                              if (totalQty <= 0) return;

                              // Create product with updated details
                              final productToUpdate = Product(
                                name: _selectedProduct!.name,
                                category: _selectedProduct!.category,
                                buyPrice:
                                    double.tryParse(_buyPriceController.text) ??
                                    _selectedProduct!.buyPrice,
                                mrp: _selectedProduct!.mrp,
                                expiryDate: _expiryDateController.text,
                                quantity: totalQty,
                                unit: _selectedProduct!.unit,
                                packSize: double.tryParse(
                                  _packSizeController.text,
                                ),
                                sellingPricePerUnit: double.tryParse(
                                  _sellingPriceController.text,
                                ),
                              );

                              // Update existing product quantity
                              await InventoryService().addProduct(
                                productToUpdate,
                              );

                              await InventoryService().recordPurchase(
                                productToUpdate,
                                totalQty,
                                _grandTotal,
                              );

                              if (!context.mounted) return;

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Stock updated successfully'),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A6FF8),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm Restock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
