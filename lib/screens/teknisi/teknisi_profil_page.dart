import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../auth/login_screen.dart';

class TeknisiProfilPage extends StatefulWidget {
  final User user;

  const TeknisiProfilPage({super.key, required this.user});

  @override
  State<TeknisiProfilPage> createState() => _TeknisiProfilPageState();
}

class _TeknisiProfilPageState extends State<TeknisiProfilPage> {
  bool _isEditing = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _specializationController = TextEditingController(
      text: widget.user.specialization ?? '-',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  List<Ticket> get _assignedTickets {
    return DataService.getTeknisiSampleTickets()
        .where((ticket) => ticket.assignedTo == widget.user.name)
        .toList();
  }

  int get _completedTicketsCount {
    return _assignedTickets
        .where((ticket) => ticket.status == 'Selesai')
        .length;
  }

  int get _inProcessTicketsCount {
    return _assignedTickets
        .where((ticket) => ticket.status == 'Dikerjakan')
        .length;
  }

  double get _averageRating {
    final ratedTickets = _assignedTickets
        .where((ticket) => ticket.rating != null)
        .toList();
    if (ratedTickets.isEmpty) return 0.0;
    final total = ratedTickets.fold<double>(
      0.0,
      (sum, ticket) => sum + (ticket.rating ?? 0),
    );
    return total / ratedTickets.length;
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
        imageQuality: 80,
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
        title: const Text('Profil Saya'),
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
                              ? Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
                                  width: 96,
                                  height: 96,
                                )
                              : CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.transparent,
                                  child: Icon(
                                    Icons.engineering,
                                    size: 54,
                                    color: const Color(0xFF1A237E),
                                  ),
                                ),
                        ),
                      ),

                      // Tombol kamera saat editing
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
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
                    'Teknisi',
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
                      'ID: TKN-${_nameController.text.hashCode.abs() % 99999}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Statistik Performa ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.assignment_turned_in_outlined,
                            label: 'Tiket Selesai',
                            value: _completedTicketsCount.toString(),
                            iconColor: Colors.white,
                            valueColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.star_outline_rounded,
                            label: 'Rating Avg',
                            value: _averageRating == 0.0
                                ? '-'
                                : _averageRating.toStringAsFixed(1),
                            iconColor: Colors.amber.shade300,
                            valueColor: Colors.amber.shade200,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.pending_actions_outlined,
                            label: 'Dalam Proses',
                            value: _inProcessTicketsCount.toString(),
                            iconColor: Colors.lightBlue.shade200,
                            valueColor: Colors.lightBlue.shade100,
                          ),
                        ),
                      ],
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
                    icon: Icons.build_outlined,
                    label: 'SPESIALISASI',
                    controller: _specializationController,
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
                    isName: true,
                  ),
                  const SizedBox(height: 24),

                  // Pengaturan Akun
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

  // ── Stat card di dalam header ──
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    bool isName = false,
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
              onChanged: isName ? (_) => setState(() {}) : null,
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
