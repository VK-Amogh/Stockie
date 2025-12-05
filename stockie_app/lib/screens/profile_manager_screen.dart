import 'package:flutter/material.dart';
import 'package:stockie_app/theme/app_theme.dart';
import 'package:stockie_app/services/auth_service.dart';

class ProfileManagerScreen extends StatefulWidget {
  const ProfileManagerScreen({super.key});

  @override
  State<ProfileManagerScreen> createState() => _ProfileManagerScreenState();
}

class _ProfileManagerScreenState extends State<ProfileManagerScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      _userData = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No user data found'),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Profile',
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
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
                  _buildSectionHeader('Personal Details'),
                  _buildDetailsCard([
                    _buildDetailRow(Icons.person, 'Name', _userData!['fullName'] ?? 'N/A'),
                    _buildDivider(),
                    _buildDetailRow(Icons.phone, 'Phone Number', _userData!['mobile'] ?? 'N/A', isMono: true),
                    _buildDivider(),
                    _buildDetailRow(Icons.mail, 'Email Address', _userData!['email'] ?? 'N/A'),
                  ]),
                  _buildSectionHeader('Shop Details'),
                  _buildDetailsCard([
                    _buildDetailRow(Icons.storefront, 'Shop Name', _userData!['shopName'] ?? 'N/A'),
                    _buildDivider(),
                    _buildDetailRow(Icons.location_on, 'Shop Address', _userData!['shopAddress'] ?? 'N/A'),
                    _buildDivider(),
                    _buildDetailRow(Icons.receipt_long, 'GSTIN', _userData!['gstin']?.isNotEmpty == true ? _userData!['gstin'] : 'N/A', isMono: true),
                  ]),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _showEditDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final mobileController = TextEditingController(text: _userData!['mobile']);
    final shopNameController = TextEditingController(text: _userData!['shopName']);
    final shopAddressController = TextEditingController(text: _userData!['shopAddress']);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: shopNameController,
                  decoration: const InputDecoration(labelText: 'Shop Name'),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: shopAddressController,
                  decoration: const InputDecoration(labelText: 'Shop Address'),
                  maxLines: 3,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final updatedDetails = {
                  'mobile': mobileController.text,
                  'shopName': shopNameController.text,
                  'shopAddress': shopAddressController.text,
                };

                final success = await AuthService.updateUser(updatedDetails);
                
                if (!mounted) return;
                Navigator.pop(context);

                if (success) {
                  _loadUserData(); // Refresh UI
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update profile')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isMono = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: isMono ? 'JetBrains Mono' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, color: Colors.grey[100]),
    );
  }
}
