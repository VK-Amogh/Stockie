import 'package:flutter/material.dart';
import 'package:stockie_app/screens/welcome_screen.dart';
import 'package:stockie_app/screens/login_screen.dart';
import 'package:stockie_app/screens/register_screen.dart';

import 'package:stockie_app/screens/main_screen.dart';
import 'package:stockie_app/screens/settings_screen.dart';
import 'package:stockie_app/screens/profile_manager_screen.dart';
import 'package:stockie_app/screens/add_purchase_screen.dart';
import 'package:stockie_app/screens/add_product_screen.dart';
import 'package:stockie_app/screens/inventory_screen.dart';
import 'package:stockie_app/screens/add_sale_screen.dart';
import 'package:stockie_app/screens/transactions_screen.dart';
import 'package:stockie_app/theme/app_theme.dart';

void main() {
  runApp(const StockieApp());
}

class StockieApp extends StatelessWidget {
  const StockieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stockie',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile_manager': (context) => const ProfileManagerScreen(),
        '/add_purchase': (context) => const AddPurchaseScreen(),
        '/add_product': (context) => const AddProductScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/add_sale': (context) => const AddSaleScreen(),
        '/transactions': (context) => const TransactionsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
