import 'package:flutter/material.dart';
import 'package:stockie_app/screens/home_screen.dart';
import 'package:stockie_app/services/inventory_service.dart';
import 'package:stockie_app/screens/inventory_screen.dart';
import 'package:stockie_app/screens/transactions_screen.dart';
import 'package:stockie_app/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    // Ensure data is loaded (e.g., on auto-login or restart)
    InventoryService().loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomeScreen(onNavigate: _onTabTapped),
          const InventoryScreen(),
          const Center(
            child: Text('Reports Screen Placeholder'),
          ), // Placeholder for Reports
          const TransactionsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.inventory, 'Inventory', 1),
            _buildNavItem(Icons.bar_chart, 'Reports', 2),
            _buildNavItem(Icons.receipt_long, 'Transactions', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primary : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? AppTheme.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
