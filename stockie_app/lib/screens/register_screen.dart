import 'package:flutter/material.dart';
import 'package:stockie_app/theme/app_theme.dart';
import 'package:stockie_app/services/auth_service.dart';
import 'package:stockie_app/services/inventory_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _gstinController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final details = {
        'fullName': _fullNameController.text,
        'mobile': _mobileController.text,
        'shopName': _shopNameController.text,
        'shopAddress': _shopAddressController.text,
        'gstin': _gstinController.text,
      };

      final success = await AuthService.register(
        _emailController.text,
        _passwordController.text,
        details,
      );

      if (!mounted) return;

      if (success) {
        await InventoryService()
            .loadData(); // Load user-specific data (initally empty)
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User already exists with this email')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Personal Details'),
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      hint: 'Enter your full name',
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      icon: Icons.phone_iphone,
                      hint: '98765 43210',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildSectionHeader('Shop Information'),
                    _buildTextField(
                      controller: _shopNameController,
                      label: 'Shop Name',
                      icon: Icons.storefront,
                      hint: "Enter your shop's name",
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _shopAddressController,
                      label: 'Shop Address',
                      icon: Icons.location_on_outlined,
                      hint: "Enter your shop's full address",
                      maxLines: 3,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _gstinController,
                      label: 'GSTIN',
                      icon: Icons.receipt_long,
                      hint: 'Enter 15-digit GSTIN',
                      optional: true,
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildSectionHeader('Account Security'),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.mail_outline,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v?.contains('@') == true ? null : 'Invalid email',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Create Password',
                      icon: Icons.lock_outline,
                      hint: 'Enter a strong password',
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (v) =>
                          v != null && v.length >= 6 ? null : 'Min 6 chars',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundLight,
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleRegister,
                  child: const Text('Register'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool optional = false,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
            if (optional)
              Text(
                ' (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: Colors.grey),
                    onPressed: onSuffixTap,
                  )
                : null,
            alignLabelWithHint: maxLines > 1,
          ),
        ),
      ],
    );
  }
}
