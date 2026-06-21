import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class PelaporProfilPage extends StatefulWidget {
  final User user;

  const PelaporProfilPage({super.key, required this.user});

  @override
  State<PelaporProfilPage> createState() => _PelaporProfilPageState();
}

class _PelaporProfilPageState extends State<PelaporProfilPage> {
  bool _isEditing = false;
  File? _profileImage; // ← simpan foto yang dipilih
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _companyController = TextEditingController(
      text: widget.user.company ?? '-',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  // ── Pilih sumber foto ──
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Foto Profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.blue.shade700),
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.green.shade700),
                ),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade700,
                    ),
                  ),
                  title: const Text('Hapus Foto'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _profileImage = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80, // kompres supaya tidak terlalu besar
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked != null) {
        setState(() => _profileImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profil Saya', style: TextStyle()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header biru + Avatar ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          color: Colors.blue.shade100,
                        ),
                        child: ClipOval(
                          child: _profileImage != null
                              // ← tampilkan foto jika sudah dipilih
                              ? Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
                                  width: 96,
                                  height: 96,
                                )
                              // ← fallback icon jika belum ada foto
                              : const CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.transparent,
                                  child: Icon(
                                    Icons.person,
                                    size: 54,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                        ),
                      ),

                      // Tombol kamera — selalu tampil saat _isEditing
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap:
                                _showImageSourceDialog, // ← langsung buka dialog
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF3949AB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nama
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Role
                  Text(
                    'Pelapor',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ID badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'ID: USR-${_nameController.text.hashCode.abs() % 99999}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),

            // ── Info Cards ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    icon: Icons.business_outlined,
                    label: 'PERUSAHAAN',
                    controller: _companyController,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    label: 'EMAIL',
                    controller: _emailController,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.phone_outlined,
                    label: 'NO. TELEPON',
                    controller: _phoneController,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'NAMA LENGKAP',
                    controller: _nameController,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 24),

                  // Account Settings
                  const Text(
                    'Pengaturan Akun',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (!_isEditing)
                    _buildSettingsTile(
                      icon: Icons.edit_outlined,
                      iconColor: const Color(0xFF1A237E),
                      bgColor: const Color(0xFF1A237E).withOpacity(0.8),
                      title: 'Edit Profil',
                      subtitle: 'Ubah informasi akun Anda',
                      onTap: () => setState(() => _isEditing = true),
                    ),

                  if (_isEditing) ...[
                    _buildSettingsTile(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green.shade700,
                      bgColor: Colors.green.shade50,
                      title: 'Simpan Perubahan',
                      subtitle: 'Simpan informasi yang telah diubah',
                      onTap: () {
                        setState(() => _isEditing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil berhasil disimpan!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildSettingsTile(
                      icon: Icons.close,
                      iconColor: Colors.orange.shade700,
                      bgColor: Colors.orange.shade50,
                      title: 'Batal',
                      subtitle: 'Batalkan perubahan',
                      onTap: () => setState(() => _isEditing = false),
                    ),
                  ],

                  const SizedBox(height: 10),

                  _buildSettingsTile(
                    icon: Icons.logout_outlined,
                    iconColor: Colors.red.shade700,
                    bgColor: Colors.red.shade50,
                    title: 'Logout',
                    subtitle: 'Keluar dari akun Anda',
                    trailingColor: Colors.red.shade400,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text(
                            'Apakah Anda yakin ingin logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await AuthService.logout();
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF1A237E)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isEditing)
            TextField(
              controller: controller,
              onChanged: label == 'NAMA LENGKAP'
                  ? (value) => context
                        .findAncestorStateOfType<_PelaporProfilPageState>()
                        ?.setState(() {})
                  : null,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1A237E)),
                ),
              ),
            )
          else
            Text(
              controller.text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? trailingColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: trailingColor ?? Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
