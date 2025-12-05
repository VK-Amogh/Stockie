import 'package:flutter/material.dart';
import 'package:stockie_app/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFA7F0FF),
                  Color(0xFFFFDAF9),
                  Color(0xFFFDF6ED),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.45,
          ),
          // Content
          Column(
            children: [
              // Header Section
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 40,
                                  height: 1.2,
                                ),
                            children: const [
                              TextSpan(text: 'Welcome to '),
                              TextSpan(
                                text: 'Stockie',
                                style: TextStyle(color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Simplify your shop, grow your business.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 18,
                              color: AppTheme.textDark,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // White Card Section
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'How Stockie Helps You',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 24),
                        // Feature Cards
                        _buildFeatureCard(
                          context,
                          icon: Icons.inventory_2_outlined,
                          title: 'Easy Inventory',
                          description: 'Keep track of your stock effortlessly, even offline.',
                          iconBgColor: const Color(0xFFA7F0FF),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(35),
                            bottomLeft: Radius.circular(15),
                          ),
                          rotate: -0.02,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          icon: Icons.point_of_sale_outlined,
                          title: 'Quick Sales',
                          description: 'Record sales in seconds with intuitive forms.',
                          iconBgColor: const Color(0xFFFFDAF9),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.circular(30),
                          ),
                          rotate: 0.02,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          icon: Icons.trending_up,
                          title: 'Track Growth',
                          description: 'See your business performance at a glance.',
                          iconBgColor: const Color(0xFFE6FFB7),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(30),
                            bottomLeft: Radius.circular(20),
                          ),
                          rotate: -0.02,
                        ),
                        const SizedBox(height: 32),
                        // Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Register'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primary, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              foregroundColor: AppTheme.primary,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color iconBgColor,
    required BorderRadius borderRadius,
    required double rotate,
  }) {
    return Transform.rotate(
      angle: rotate,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: borderRadius,
              ),
              child: Icon(icon, color: AppTheme.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
