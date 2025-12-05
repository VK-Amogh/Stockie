import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stockie_app/models/invoice.dart';
import 'package:stockie_app/services/inventory_service.dart';
import 'package:stockie_app/theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundLight,
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button Removed for Tab View
                      // Container(
                      //   width: 40,
                      //   height: 40,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: IconButton(
                      //     icon: const Icon(
                      //       Icons.arrow_back,
                      //       color: AppTheme.textDark,
                      //     ),
                      //     onPressed: () => Navigator.pop(context),
                      //     padding: EdgeInsets.zero,
                      //   ),
                      // ),
                      // Actions
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: AppTheme.textDark,
                              ),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.filter_list,
                                color: AppTheme.textDark,
                              ),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), // Gap
                  Text(
                    'Transactions',
                    style: GoogleFonts.inter(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textDark.withOpacity(
                  0.6,
                ), // Darker grey for better visibility
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3, // Slightly thicker indicator
                labelStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight
                      .w600, // Slightly bolder for unselected to ensure visibility
                ),
                tabs: const [
                  Tab(
                    height: 50, // Fixed height to prevent clipping
                    child: Center(child: Text('Sale Invoices')),
                  ),
                  Tab(
                    height: 50, // Fixed height to prevent clipping
                    child: Center(child: Text('Purchase Invoices')),
                  ),
                ],
              ),
            ),
            // Tab View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInvoiceList(isSale: true),
                  _buildInvoiceList(isSale: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceList({required bool isSale}) {
    return AnimatedBuilder(
      animation: InventoryService(),
      builder: (context, child) {
        final allInvoices = InventoryService().invoices;
        final filteredInvoices = allInvoices
            .where(
              (inv) => isSale
                  ? inv.type == InvoiceType.sale
                  : inv.type == InvoiceType.purchase,
            )
            .toList();

        // Sort by date descending
        filteredInvoices.sort((a, b) => b.date.compareTo(a.date));

        if (filteredInvoices.isEmpty) {
          return Center(
            child: Text(
              'No ${isSale ? 'sale' : 'purchase'} invoices found',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredInvoices.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final invoice = filteredInvoices[index];
            return _buildInvoiceCard(
              id: invoice.id,
              date: DateFormat('dd MMM yyyy, hh:mm a').format(invoice.date),
              amount: '₹${invoice.totalAmount.toStringAsFixed(2)}',
              status: invoice.status,
              statusColor: invoice.status == 'Paid'
                  ? AppTheme.success
                  : AppTheme.alert,
              isSale: isSale,
              items: invoice.items
                  .map(
                    (item) => {
                      'name': item.productName,
                      'qty': item.quantity.toString(),
                      'unit': item.unit,
                      'packSize': item.packSize?.toString() ?? '',
                      'rate': '₹${item.price.toStringAsFixed(2)}',
                      'total':
                          '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                      'expiry': item.expiryDate,
                    },
                  )
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildInvoiceCard({
    required String id,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required bool isSale,
    required List<Map<String, String>> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice #$id',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...items.map((item) {
            String qtyDisplay;
            double qty = double.tryParse(item['qty']!) ?? 0;
            double packSize = double.tryParse(item['packSize']!) ?? 0;

            if (packSize > 0) {
              if (isSale) {
                // For Sales: qty is the Total Quantity (Weight)
                // We want to show: "50 kg   10 Packs" ONLY if it's full packs
                // Strict check: Only show "Packs" if quantity equals EXACTLY one pack size
                // matching the pricing logic.
                bool isFullPacks = (qty - packSize).abs() < 0.0001;

                String qtyStr = qty.toStringAsFixed(
                  qty.truncateToDouble() == qty ? 0 : 2,
                );

                if (isFullPacks) {
                  String packsStr = '1'; // Strictly 1 pack
                  qtyDisplay = '$qtyStr ${item['unit']}   $packsStr Pack';
                } else {
                  // Loose/Partial sale -> Don't show "Packs" count
                  qtyDisplay = '$qtyStr ${item['unit']}';
                }
              } else {
                // For Purchases: qty is the Pack Count
                // We want to show: "10 Packs   50 kg"
                double totalQty = qty * packSize;

                String packsStr = qty.toStringAsFixed(
                  qty.truncateToDouble() == qty ? 0 : 1,
                );
                String totalStr = totalQty.toStringAsFixed(
                  totalQty.truncateToDouble() == totalQty ? 0 : 2,
                );

                qtyDisplay = '$packsStr Packs   $totalStr ${item['unit']}';
              }
            } else {
              String qtyStr = qty.toStringAsFixed(
                qty.truncateToDouble() == qty ? 0 : 2,
              );
              qtyDisplay = '$qtyStr ${item['unit']}';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['name']!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        qtyDisplay,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rate: ${item['rate']} / ${item['unit']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      Text(
                        'Total: ${item['total']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
