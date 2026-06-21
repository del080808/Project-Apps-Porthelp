import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// Model lokal untuk user management
class _UserData {
  final String id;
  String name;
  String email;
  String phone;
  String role; // 'pelapor' | 'teknisi' | 'admin'
  String divisi;
  bool isActive;
  final String joinDate;
  int totalTickets;

  _UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.divisi,
    required this.isActive,
    required this.joinDate,
    required this.totalTickets,
  });
}

class AdminManajemenUserPage extends StatefulWidget {
  const AdminManajemenUserPage({super.key});

  @override
  State<AdminManajemenUserPage> createState() => _AdminManajemenUserPageState();
}

class _AdminManajemenUserPageState extends State<AdminManajemenUserPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<_UserData> _users = [
    _UserData(id: 'USR-001', name: 'Budi Santoso', email: 'budi@company.com', phone: '0812-1111-2222', role: 'pelapor', divisi: 'Finance', isActive: true, joinDate: '1 Jan 2025', totalTickets: 5),
    _UserData(id: 'USR-002', name: 'Siti Rahayu', email: 'siti@company.com', phone: '0813-2222-3333', role: 'pelapor', divisi: 'HR', isActive: true, joinDate: '15 Feb 2025', totalTickets: 2),
    _UserData(id: 'USR-003', name: 'Rudi Hartono', email: 'rudi@company.com', phone: '0814-3333-4444', role: 'pelapor', divisi: 'Marketing', isActive: true, joinDate: '3 Mar 2025', totalTickets: 3),
    _UserData(id: 'USR-004', name: 'Andi Wijaya', email: 'andi@company.com', phone: '0812-3456-7890', role: 'teknisi', divisi: 'Infrastructure', isActive: true, joinDate: '1 Jan 2024', totalTickets: 15),
    _UserData(id: 'USR-005', name: 'Budi Santoso TK', email: 'budi.tk@company.com', phone: '0813-4567-8901', role: 'teknisi', divisi: 'Development', isActive: true, joinDate: '1 Jan 2024', totalTickets: 12),
    _UserData(id: 'USR-006', name: 'Citra Dewi', email: 'citra@company.com', phone: '0814-5678-9012', role: 'teknisi', divisi: 'Database', isActive: false, joinDate: '1 Mar 2024', totalTickets: 8),
    _UserData(id: 'USR-007', name: 'Admin Utama', email: 'admin@porthelp.com', phone: '0811-0000-0001', role: 'admin', divisi: 'IT Management', isActive: true, joinDate: '1 Jan 2024', totalTickets: 0),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_UserData> _filtered(String role) {
    return _users.where((u) {
      final matchRole = u.role == role;
      final matchSearch = _searchQuery.isEmpty ||
          u.name.toLowerCase().contains(_searchQuery) ||
          u.email.toLowerCase().contains(_searchQuery) ||
          u.divisi.toLowerCase().contains(_searchQuery);
      return matchRole && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text('Manajemen User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => _showTambahUserDialog(),
            tooltip: 'Tambah User',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Pelapor (${_filtered('pelapor').length})'),
            Tab(text: 'Teknisi (${_filtered('teknisi').length})'),
            Tab(text: 'Admin (${_filtered('admin').length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList('pelapor'),
                _buildUserList('teknisi'),
                _buildUserList('admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Cari nama, email, atau divisi...',
          hintStyle: const TextStyle(fontSize: 13, color: AppPalette.textSecondary),
          prefixIcon: const Icon(Icons.search, size: 20, color: AppPalette.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => _searchCtrl.clear())
              : null,
          filled: true,
          fillColor: const Color(0xFFF0F3FA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildUserList(String role) {
    final users = _filtered(role);
    if (users.isEmpty) {
      return const Center(child: Text('Tidak ada user', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (_, i) => _buildUserCard(users[i]),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return const Color(0xFF5B21B6);
      case 'teknisi': return AppPalette.primary;
      default: return const Color(0xFF059669);
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin': return 'Admin';
      case 'teknisi': return 'Teknisi';
      default: return 'Pelapor';
    }
  }

  Widget _buildUserCard(_UserData user) {
    final color = _roleColor(user.role);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withValues(alpha: 0.04), offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Text(user.name.substring(0, 1),
                    style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              ),
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: user.isActive ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(user.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(_roleLabel(user.role),
                          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(user.email, style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.business_outlined, size: 11, color: AppPalette.textSecondary),
                    const SizedBox(width: 4),
                    Text(user.divisi, style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
                    const SizedBox(width: 10),
                    const Icon(Icons.confirmation_number_outlined, size: 11, color: AppPalette.textSecondary),
                    const SizedBox(width: 4),
                    Text('${user.totalTickets} tiket', style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: AppPalette.textSecondary),
            onSelected: (action) => _handleUserAction(action, user),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
              PopupMenuItem(
                value: 'toggle',
                child: Row(children: [
                  Icon(user.isActive ? Icons.block : Icons.check_circle_outline, size: 16),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                ]),
              ),
              const PopupMenuItem(value: 'reset', child: Row(children: [Icon(Icons.lock_reset, size: 16), SizedBox(width: 8), Text('Reset Password')])),
              if (user.role != 'admin')
                const PopupMenuItem(value: 'hapus', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
    );
  }

  void _handleUserAction(String action, _UserData user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'toggle':
        setState(() => user.isActive = !user.isActive);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${user.name} ${user.isActive ? 'diaktifkan' : 'dinonaktifkan'}'),
          behavior: SnackBarBehavior.floating,
        ));
        break;
      case 'reset':
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Link reset password dikirim ke ${user.email}'),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ));
        break;
      case 'hapus':
        _konfirmasiHapus(user);
        break;
    }
  }

  void _konfirmasiHapus(_UserData user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Hapus akun ${user.name}? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              setState(() => _users.remove(user));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} dihapus'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(_UserData user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    final divisiCtrl = TextEditingController(text: user.divisi);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField('Nama', nameCtrl),
              const SizedBox(height: 12),
              _dialogField('Email', emailCtrl),
              const SizedBox(height: 12),
              _dialogField('Telepon', phoneCtrl),
              const SizedBox(height: 12),
              _dialogField('Divisi', divisiCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                user.name = nameCtrl.text;
                user.email = emailCtrl.text;
                user.phone = phoneCtrl.text;
                user.divisi = divisiCtrl.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data user diperbarui'), backgroundColor: Color(0xFF059669), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTambahUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final divisiCtrl = TextEditingController();
    String selectedRole = 'pelapor';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Tambah User Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Nama Lengkap', nameCtrl),
                const SizedBox(height: 12),
                _dialogField('Email', emailCtrl),
                const SizedBox(height: 12),
                _dialogField('Telepon', phoneCtrl),
                const SizedBox(height: 12),
                _dialogField('Divisi', divisiCtrl),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ['pelapor', 'teknisi', 'admin'].map((r) =>
                      DropdownMenuItem(value: r, child: Text(r.substring(0, 1).toUpperCase() + r.substring(1)))).toList(),
                  onChanged: (v) => setS(() => selectedRole = v!),
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
                setState(() {
                  _users.add(_UserData(
                    id: 'USR-${_users.length + 1}',
                    name: nameCtrl.text,
                    email: emailCtrl.text,
                    phone: phoneCtrl.text,
                    role: selectedRole,
                    divisi: divisiCtrl.text,
                    isActive: true,
                    joinDate: 'Hari ini',
                    totalTickets: 0,
                  ));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User baru berhasil ditambahkan'), backgroundColor: Color(0xFF059669), behavior: SnackBarBehavior.floating),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary),
              child: const Text('Tambah', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
