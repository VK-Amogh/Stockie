import 'package:flutter/material.dart';
import 'package:stockie_app/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Settings',
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Manage Profile',
                subtitle: 'Shop name, phone number',
                onTap: () {
                  Navigator.pushNamed(context, '/profile_manager');
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.group,
                title: 'Manage Roles',
                subtitle: 'Add or edit staff permissions',
                onTap: () {},
              ),
            ]),
            _buildSectionHeader('Data Management'),
            _buildSettingsGroup([
              _buildBackupTile(),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () {},
              ),
            ]),
            _buildSectionHeader('Business Settings'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.percent,
                title: 'GST & Tax Settings',
                subtitle: 'Configure tax rates and details',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.print,
                title: 'Printer & Hardware',
                subtitle: 'Connect to a receipt printer',
                onTap: () {},
              ),
            ]),
            _buildSectionHeader('App Information'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'Version 1.2.3',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  // Logout logic could go here
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                icon: const Icon(Icons.logout, color: AppTheme.alert),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: AppTheme.alert, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.alert.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
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

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14))
          : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[100], indent: 16, endIndent: 16);
  }

  Widget _buildBackupTile() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_upload, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auto Backup',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    Text(
                      'Last backup: Today, 8:15 PM',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Switch(
                value: true,
                onChanged: (val) {},
                activeColor: AppTheme.accent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Backup Now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    foregroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Restore Data'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
