import 'package:flutter/material.dart';
import 'package:stockie_app/theme/app_theme.dart';
import '../services/inventory_service.dart';
import 'inventory_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.all(16),
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
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuC_o-MvFd2LwVbHVCUNJDo7l1tcmA-PPn5wAUZQtuB5n_yInhlQKfs1giIRugBzS3JEjrm6tEOCIjvtoelOaelK7o9OPXbi9UOK8-h6Zo5R2Mg2oyXcmTmYVgvXFueMjzumidJnj6arkeSmyMKgp8R-ik5ubObrKnOJq3rEddTCLysBToTxqTsJWpluGYxhv_-6fCi6Ij74tuQb8GE9ex5e2edkHvVsjh2lM8p_Rn9b-dS57QrmLU-1Wno1d1fZJN8Sj9FYYpqk-rAh',
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Good Morning, Shopkeeper',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: AnimatedBuilder(
                        animation: InventoryService(),
                        builder: (context, child) {
                          // Use helpers if available, or just recalculate
                          // Ideally use helpers I added to InventoryService
                          final inventory = InventoryService();
                          final sales = inventory.getTodaysSales();
                          final profit = inventory.getTodaysProfit();
                          final totalStock = inventory.totalProductsCount;
                          final lowStock = inventory.lowStockCount;
                          final outStock = inventory.outOfStockCount;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Sales & Profit Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Today\'s Sales',
                                      '₹${sales.toStringAsFixed(0)}',
                                      '+5.2%',
                                      AppTheme.success,
                                      Icons.arrow_upward,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Today\'s Profit',
                                      '₹${profit.toStringAsFixed(0)}',
                                      '+3.1%',
                                      AppTheme.success,
                                      Icons.arrow_upward,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Inventory Status Box (Premium)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Inventory Status',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          _buildInventoryStat(
                                            'Total Items',
                                            totalStock.toString(),
                                            Colors.green.shade50,
                                            Colors.green.shade700,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const InventoryScreen(
                                                        filterType:
                                                            InventoryFilterType
                                                                .all,
                                                        sortByUrgency: true,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 12),
                                          _buildInventoryStat(
                                            'Low Stock',
                                            lowStock.toString(),
                                            Colors.orange.shade50,
                                            Colors.orange.shade800,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const InventoryScreen(
                                                        filterType:
                                                            InventoryFilterType
                                                                .low,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 12),
                                          _buildInventoryStat(
                                            'Out of Stock',
                                            outStock.toString(),
                                            Colors.red.shade50,
                                            Colors.red.shade700,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const InventoryScreen(
                                                        filterType:
                                                            InventoryFilterType
                                                                .outOfStock,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          _buildActionCard(
                            Icons.add,
                            'Add Sale',
                            'Record a new transaction',
                            onTap: () =>
                                Navigator.pushNamed(context, '/add_sale'),
                          ),
                          _buildActionCard(
                            Icons.shopping_cart,
                            'Add Purchase',
                            'Update your stock',
                            onTap: () =>
                                Navigator.pushNamed(context, '/add_purchase'),
                          ),
                          _buildActionCard(
                            Icons.inventory_2,
                            'View Inventory',
                            'Check all items',
                            onTap: () => onNavigate?.call(1),
                          ),
                          _buildActionCard(
                            Icons.qr_code_scanner,
                            'Scan Barcode',
                            'Quickly add products',
                          ),
                        ],
                      ),
                    ),
                    // AI Insights
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'AI Insights & Suggestions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildInsightCard(
                            Icons.warning_amber_rounded,
                            AppTheme.alert,
                            'Low Stock Alert',
                            'Parle-G biscuits are running low. Only 5 units left.',
                            action: 'Reorder',
                          ),
                          const SizedBox(height: 8),
                          _buildInsightCard(
                            Icons.trending_up,
                            AppTheme.accent,
                            'Sales Trend',
                            'Lays Chips are selling fast this week.',
                          ),
                          const SizedBox(height: 8),
                          _buildInsightCard(
                            Icons.insights,
                            AppTheme.primary,
                            'Demand Forecast',
                            'Expecting higher demand for cold drinks on Saturday.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String change,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: 158, // Approximate width from HTML
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppTheme.primary, size: 28),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    IconData icon,
    Color color,
    String title,
    String description, {
    String? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (action != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                action,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInventoryStat(
    String label,
    String value,
    Color bgColor,
    Color textColor, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
