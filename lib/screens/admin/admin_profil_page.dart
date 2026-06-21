import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'profil_fitur/admin_backup_page.dart';
import 'profil_fitur/admin_laporan_page.dart';
import 'profil_fitur/admin_manajemen_user_page.dart';
import 'profil_fitur/admin_panduan_page.dart';
import 'profil_fitur/admin_pengaturan_page.dart';

class AdminProfilPage extends StatelessWidget {
  final User user;
  const AdminProfilPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildMenuSection(context),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: const BoxDecoration(gradient: AppPalette.heroGradient),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: Text(
                  user.name.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: AppPalette.primary,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Administrator',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Akun',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppPalette.textPrimary,
              ),
            ),
            const Divider(height: 20),
            _infoRow(Icons.person_outline, 'Nama', user.name),
            _infoRow(Icons.email_outlined, 'Email', user.email),
            _infoRow(Icons.phone_outlined, 'Telepon', user.phone),
            _infoRow(
              Icons.business_outlined,
              'Organisasi',
              user.company ?? 'PortHelp IT Support',
            ),
            _infoRow(Icons.shield_outlined, 'Role', 'Admin Sistem'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppPalette.primary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: AppPalette.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menus = [
      _MenuItem(
        icon: Icons.bar_chart_outlined,
        label: 'Laporan & Statistik',
        subtitle: 'Lihat performa helpdesk',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminLaporanPage()),
        ),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        label: 'Pengaturan Sistem',
        subtitle: 'Konfigurasi aplikasi',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminPengaturanPage()),
        ),
      ),
      _MenuItem(
        icon: Icons.people_outline,
        label: 'Manajemen User',
        subtitle: 'Kelola akun pengguna',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminManajemenUserPage()),
        ),
      ),
      _MenuItem(
        icon: Icons.backup_outlined,
        label: 'Backup Data',
        subtitle: 'Ekspor data tiket',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminBackupPage()),
        ),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'Panduan Admin',
        subtitle: 'Dokumentasi sistem',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminPanduanPage()),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: menus
              .asMap()
              .entries
              .map(
                (e) => Column(
                  children: [
                    _buildMenuTile(e.value),
                    if (e.key < menus.length - 1)
                      const Divider(height: 1, indent: 56),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMenuTile(_MenuItem menu) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppPalette.primary.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(menu.icon, color: AppPalette.primary, size: 18),
      ),
      title: Text(
        menu.label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        menu.subtitle,
        style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppPalette.textSecondary,
        size: 18,
      ),
      onTap: menu.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout, color: Colors.red, size: 18),
          label: const Text(
            'Keluar',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini akan segera tersedia'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
}
