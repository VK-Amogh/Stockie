import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../services/inventory_service.dart';
import 'main_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _packSizeController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  double _grandTotal = 0.0;
  String _selectedUnit = 'Pcs';

  static const List<String> _categories = [
    'Staples & Groceries',
    'Edible Oils & Ghee',
    'Spices & Masalas',
    'Snacks & Namkeens',
    'Biscuits & Bakery',
    'Beverages',
    'Packaged Foods',
    'Dairy & Refrigerated Items',
    'Confectionery',
    'Personal Care',
    'Home Care',
    'Baby Care',
    'Hygiene & Health (OTC)',
    'Pet Supplies',
    'Stationery & Office',
    'Household Utilities',
    'Kitchen Essentials',
    'Pooja Items',
    'Tobacco & Allied Items',
    'Seasonal & Miscellaneous',
  ];

  @override
  void initState() {
    super.initState();
    _buyPriceController.addListener(_calculateTotal);
    _mrpController.addListener(_calculateTotal);
    _quantityController.addListener(_calculateTotal);
    _packSizeController.addListener(_calculateTotal);
    // Add listener to rebuild UI when pack size changes (for dynamic label)
    _packSizeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _buyPriceController.dispose();
    _mrpController.dispose();
    _expiryDateController.dispose();
    _quantityController.dispose();
    _packSizeController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    double price = double.tryParse(_buyPriceController.text) ?? 0.0;
    double qty = double.tryParse(_quantityController.text) ?? 0.0;
    setState(() {
      _grandTotal = price * qty;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Add New Product',
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
                        // Product Name
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Product Name',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D111C),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter product name',
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

                        // Category
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Category (Optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D111C),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Autocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<String>.empty();
                                      }
                                      return _categories.where((String option) {
                                        return option.toLowerCase().contains(
                                          textEditingValue.text.toLowerCase(),
                                        );
                                      });
                                    },
                                onSelected: (String selection) {
                                  _categoryController.text = selection;
                                },
                                fieldViewBuilder:
                                    (
                                      context,
                                      textEditingController,
                                      focusNode,
                                      onFieldSubmitted,
                                    ) {
                                      // Sync controllers
                                      if (_categoryController.text.isNotEmpty &&
                                          textEditingController.text.isEmpty) {
                                        textEditingController.text =
                                            _categoryController.text;
                                      }
                                      return TextField(
                                        controller: textEditingController,
                                        focusNode: focusNode,
                                        onChanged: (value) {
                                          _categoryController.text = value;
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Search or enter category',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF7F9FC),
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
                                          suffixIcon: PopupMenuButton<String>(
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                            ),
                                            onSelected: (String value) {
                                              _categoryController.text = value;
                                              textEditingController.text =
                                                  value;
                                            },
                                            itemBuilder:
                                                (BuildContext context) {
                                                  return _categories.map((
                                                    String choice,
                                                  ) {
                                                    return PopupMenuItem<
                                                      String
                                                    >(
                                                      value: choice,
                                                      child: Text(choice),
                                                    );
                                                  }).toList();
                                                },
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFCED6E9)),

                        // Quantity & Unit
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE7EAF4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.scale,
                                      color: Color(0xFF0D111C),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Quantity & Size',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D111C),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  // Quantity (Count)
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Quantity (Count)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0D111C),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: _quantityController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*'),
                                            ),
                                          ],
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: TextStyle(
                                              color: Colors.grey.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF7F9FC),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCED6E9),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCED6E9),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Pack Size
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Size per Item (Optional)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0D111C),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: _packSizeController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: InputDecoration(
                                            hintText: 'Optional',
                                            hintStyle: TextStyle(
                                              color: Colors.grey.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF7F9FC),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCED6E9),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCED6E9),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Unit
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Unit',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0D111C),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF7F9FC),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFCED6E9),
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: _selectedUnit,
                                              items:
                                                  [
                                                    'Pcs',
                                                    'Kg',
                                                    'g',
                                                    'L',
                                                    'ml',
                                                    'mg',
                                                  ].map((String value) {
                                                    return DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _selectedUnit = newValue!;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Total Stock Preview
                              if (_packSizeController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Total Stock: ${(double.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_packSizeController.text) ?? 1)} $_selectedUnit',
                                    style: const TextStyle(
                                      color: Color(0xFF3A6FF8),
                                      fontWeight: FontWeight.bold,
                                    ),
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

                        // Buy Price & MRP
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
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixText: '₹ ',
                                        hintText: '0.00',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF7F9FC),
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
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixText: '₹ ',
                                        hintText: '0.00',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF7F9FC),
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
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFCED6E9)),

                        // Expiry Date
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
                                readOnly: true,
                                onTap: () => _selectDate(context),
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
                      ],
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
                        'Grand Total',
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
                      onPressed: () async {
                        if (_nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter product name'),
                            ),
                          );
                          return;
                        }

                        final product = Product(
                          name: _nameController.text,
                          category: _categoryController.text,
                          buyPrice:
                              double.tryParse(_buyPriceController.text) ?? 0.0,
                          mrp: double.tryParse(_mrpController.text) ?? 0.0,
                          expiryDate: _expiryDateController.text,
                          quantity:
                              (double.tryParse(_quantityController.text) ??
                                  0.0) *
                              (double.tryParse(_packSizeController.text) ??
                                  1.0),
                          unit: _selectedUnit,
                          packSize: double.tryParse(_packSizeController.text),
                          sellingPricePerUnit: double.tryParse(
                            _sellingPriceController.text,
                          ),
                        );

                        await InventoryService().addProduct(product);
                        await InventoryService().recordPurchase(
                          product,
                          double.parse(_quantityController.text),
                          _grandTotal,
                        );

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MainScreen(initialIndex: 1),
                          ),
                          (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product added successfully'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A6FF8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Product',
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
