import 'package:flutter/material.dart';
import 'package:stockie_app/theme/app_theme.dart';

import '../services/inventory_service.dart';

// Filter types for the inventory screen
enum InventoryFilterType { all, low, outOfStock }

class InventoryScreen extends StatefulWidget {
  final bool sortByUrgency;
  final InventoryFilterType filterType;

  const InventoryScreen({
    super.key,
    this.sortByUrgency = false,
    this.filterType = InventoryFilterType.all,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'All',
    'Snacks',
    'Beverages',
    'Low Stock',
    'Out of Stock',
  ];

  @override
  void initState() {
    super.initState();
    // Set initial filter based on the passed type
    switch (widget.filterType) {
      case InventoryFilterType.low:
        _selectedFilterIndex = 3; // 'Low Stock' index
        break;
      case InventoryFilterType.outOfStock:
        _selectedFilterIndex = 4; // 'Out of Stock' index
        break;
      case InventoryFilterType.all:
      default:
        _selectedFilterIndex = 0; // 'All'
        break;
    }
  }

  Color get _themeColor {
    switch (widget.filterType) {
      case InventoryFilterType.low:
        return AppTheme.alert; // Yellow/Orange
      case InventoryFilterType.outOfStock:
        return Colors.red;
      case InventoryFilterType.all:
      default:
        return AppTheme.primary;
    }
  }

  String get _title {
    switch (widget.filterType) {
      case InventoryFilterType.low:
        return 'Low Stock Items';
      case InventoryFilterType.outOfStock:
        return 'Out of Stock';
      case InventoryFilterType.all:
      default:
        return widget.sortByUrgency ? 'Inventory Status' : 'Products';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSpecialMode = widget.filterType != InventoryFilterType.all;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight.withOpacity(0.8),
        elevation: 0,
        leading: (widget.sortByUrgency || isSpecialMode)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppTheme.textDark,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
        title: Text(
          _title,
          style: TextStyle(
            color: isSpecialMode ? _themeColor : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: AppTheme.textDark),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips - Only show if not in special mode
          if (!isSpecialMode)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Product List
          Expanded(
            child: AnimatedBuilder(
              animation: InventoryService(),
              builder: (context, child) {
                final groupedProducts = InventoryService()
                    .getProductsGroupedByName();
                List<String> productNames = groupedProducts.keys.toList();

                final activeFilterIndex = isSpecialMode
                    ? -1
                    : _selectedFilterIndex;

                // Filter logic
                productNames = productNames.where((name) {
                  final qty = InventoryService().getTotalQuantity(name);
                  final variants = groupedProducts[name]!;
                  final category = variants.first.category;

                  if (isSpecialMode) {
                    if (widget.filterType == InventoryFilterType.low) {
                      return qty > 0 && qty <= 10;
                    } else if (widget.filterType ==
                        InventoryFilterType.outOfStock) {
                      return qty <= 0;
                    } else {
                      return true;
                    }
                  } else {
                    switch (activeFilterIndex) {
                      case 1:
                        return category == 'Snacks';
                      case 2:
                        return category == 'Beverages';
                      case 3:
                        return qty > 0 && qty <= 10;
                      case 4:
                        return qty <= 0;
                      default:
                        return true;
                    }
                  }
                }).toList();

                if (widget.sortByUrgency) {
                  productNames.sort((a, b) {
                    double qtyA = InventoryService().getTotalQuantity(a);
                    double qtyB = InventoryService().getTotalQuantity(b);
                    return qtyA.compareTo(qtyB);
                  });
                }

                if (productNames.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: productNames.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final name = productNames[index];
                    final batches = groupedProducts[name]!;
                    final totalQuantity = InventoryService().getTotalQuantity(
                      name,
                    );

                    batches.sort((a, b) {
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

                    final isOutOfStock = totalQuantity == 0;
                    final isLowStock = totalQuantity < 10 && !isOutOfStock;
                    final unit = batches.isNotEmpty ? batches.first.unit : '';

                    double totalPacks = 0;
                    bool hasPackSize = false;
                    for (var b in batches) {
                      if (b.packSize != null && b.packSize! > 0) {
                        totalPacks += (b.quantity / b.packSize!).ceil();
                        hasPackSize = true;
                      }
                    }

                    String subtitleText;
                    if (isOutOfStock) {
                      subtitleText = 'Out of Stock';
                    } else if (hasPackSize) {
                      subtitleText =
                          '${totalPacks.toInt()} Packs (${totalQuantity.toStringAsFixed(1)} $unit) total${isLowStock ? ' (Low)' : ''}';
                    } else {
                      subtitleText =
                          '${totalQuantity.toStringAsFixed(1)} $unit total${isLowStock ? ' (Low)' : ''}';
                    }

                    // Border color based on status or special mode
                    Color borderColor = Colors.transparent;
                    if (isSpecialMode) {
                      // Apply requested colors
                      if (widget.filterType == InventoryFilterType.low) {
                        borderColor = AppTheme.alert; // Yellow/Orange
                      } else if (widget.filterType ==
                          InventoryFilterType.outOfStock) {
                        borderColor = Colors.red;
                      } else {
                        borderColor = Colors.green; // Available
                      }
                    } else {
                      // Standard logic
                      if (isOutOfStock)
                        borderColor = Colors.red.withOpacity(0.5);
                      else if (isLowStock)
                        borderColor = AppTheme.alert.withOpacity(0.5);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSpecialMode
                              ? borderColor
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade200,
                            ),
                            child: const Icon(
                              Icons.inventory_2,
                              color: Colors.grey,
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          subtitle: Text(
                            subtitleText,
                            style: TextStyle(
                              fontSize: 14,
                              color: isLowStock
                                  ? AppTheme.alert
                                  : (isOutOfStock
                                        ? Colors.grey
                                        : AppTheme.success),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: batches.map((batch) {
                            final isOldest = batch == batches.first;
                            final isNewest =
                                batch == batches.last && batches.length > 1;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFFF0F2F5)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Stock Type Indicator
                                  if (batches.length > 1)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: isOldest
                                            ? Colors.red.withOpacity(0.1)
                                            : (isNewest
                                                  ? Colors.green.withOpacity(
                                                      0.1,
                                                    )
                                                  : Colors.grey.withOpacity(
                                                      0.1,
                                                    )),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isOldest
                                            ? 'Old Stock'
                                            : (isNewest
                                                  ? 'New Stock'
                                                  : 'Stock'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isOldest
                                              ? Colors.red
                                              : (isNewest
                                                    ? Colors.green
                                                    : Colors.grey),
                                        ),
                                      ),
                                    ),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'MRP: ₹${batch.mrp} | Buy: ₹${batch.buyPrice}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        Text(
                                          'Exp: ${batch.expiryDate}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    (batch.packSize != null &&
                                            batch.packSize! > 0)
                                        ? '${(batch.quantity / batch.packSize!).ceil()} Packs (${batch.quantity.toStringAsFixed(1)} ${batch.unit})'
                                        : 'x${batch.quantity.toStringAsFixed(1)} ${batch.unit}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_product');
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
