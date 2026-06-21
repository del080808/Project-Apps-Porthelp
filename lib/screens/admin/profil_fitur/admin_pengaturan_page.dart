import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminPengaturanPage extends StatefulWidget {
  const AdminPengaturanPage({super.key});

  @override
  State<AdminPengaturanPage> createState() => _AdminPengaturanPageState();
}

class _AdminPengaturanPageState extends State<AdminPengaturanPage> {
  // SLA settings
  int _slaUrgentJam = 4;
  int _slaHighJam = 24;
  int _slaMediumJam = 72;
  int _slaLowJam = 168;

  // Notifikasi settings
  bool _notifEmailAktif = true;
  bool _notifPushAktif = true;
  bool _notifSLAAlert = true;
  bool _notifTicketBaru = true;
  bool _notifStatusUpdate = false;

  // Sistem settings
  bool _maintenanceMode = false;
  bool _autoAssign = false;
  bool _requireApproval = true;
  String _bahasa = 'Indonesia';
  String _timezone = 'WIB (UTC+7)';

  // Jam operasional
  String _jamBuka = '08:00';
  String _jamTutup = '17:00';

  bool _hasChanges = false;

  void _markChanged() => setState(() => _hasChanges = true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text('Pengaturan Sistem',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _simpanPengaturan,
              child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── SLA Configuration ──
          _buildSectionHeader(Icons.timer_outlined, 'Konfigurasi SLA', 'Atur batas waktu penanganan tiket'),
          _buildCard(
            children: [
              _buildSlaSetting('Urgent', _slaUrgentJam, (v) {
                setState(() { _slaUrgentJam = v; _hasChanges = true; });
              }, Colors.red),
              const Divider(),
              _buildSlaSetting('High', _slaHighJam, (v) {
                setState(() { _slaHighJam = v; _hasChanges = true; });
              }, Colors.orange),
              const Divider(),
              _buildSlaSetting('Medium', _slaMediumJam, (v) {
                setState(() { _slaMediumJam = v; _hasChanges = true; });
              }, Colors.blue),
              const Divider(),
              _buildSlaSetting('Low', _slaLowJam, (v) {
                setState(() { _slaLowJam = v; _hasChanges = true; });
              }, Colors.grey),
            ],
          ),

          const SizedBox(height: 16),

          // ── Notifikasi ──
          _buildSectionHeader(Icons.notifications_outlined, 'Pengaturan Notifikasi', 'Atur kapan sistem mengirim notifikasi'),
          _buildCard(
            children: [
              _buildSwitch('Notifikasi Email', 'Kirim notifikasi via email', _notifEmailAktif, (v) {
                setState(() { _notifEmailAktif = v; _hasChanges = true; });
              }),
              const Divider(),
              _buildSwitch('Notifikasi Push', 'Kirim push notification ke app', _notifPushAktif, (v) {
                setState(() { _notifPushAktif = v; _hasChanges = true; });
              }),
              const Divider(),
              _buildSwitch('Alert SLA Kritis', 'Notifikasi saat tiket mendekati deadline', _notifSLAAlert, (v) {
                setState(() { _notifSLAAlert = v; _hasChanges = true; });
              }),
              const Divider(),
              _buildSwitch('Tiket Baru', 'Notifikasi saat ada tiket masuk', _notifTicketBaru, (v) {
                setState(() { _notifTicketBaru = v; _hasChanges = true; });
              }),
              const Divider(),
              _buildSwitch('Update Status', 'Notifikasi setiap perubahan status', _notifStatusUpdate, (v) {
                setState(() { _notifStatusUpdate = v; _hasChanges = true; });
              }),
            ],
          ),

          const SizedBox(height: 16),

          // ── Jam Operasional ──
          _buildSectionHeader(Icons.access_time, 'Jam Operasional', 'Jam layanan helpdesk aktif'),
          _buildCard(
            children: [
              _buildDropdownRow('Jam Buka', _jamBuka, ['07:00', '08:00', '09:00'], (v) {
                setState(() { _jamBuka = v!; _hasChanges = true; });
              }),
              const Divider(),
              _buildDropdownRow('Jam Tutup', _jamTutup, ['16:00', '17:00', '18:00', '20:00', '23:59'], (v) {
                setState(() { _jamTutup = v!; _hasChanges = true; });
              }),
            ],
          ),

          const SizedBox(height: 16),

          // ── Sistem Umum ──
          _buildSectionHeader(Icons.settings_outlined, 'Pengaturan Umum', 'Konfigurasi perilaku sistem'),
          _buildCard(
            children: [
              _buildDropdownRow('Bahasa', _bahasa, ['Indonesia', 'English'], (v) {
                setState(() { _bahasa = v!; _hasChanges = true; });
              }),
              const Divider(),
              _buildDropdownRow('Timezone', _timezone, ['WIB (UTC+7)', 'WITA (UTC+8)', 'WIT (UTC+9)'], (v) {
                setState(() { _timezone = v!; _hasChanges = true; });
              }),
              const Divider(),
              _buildSwitch('Auto-Assign Teknisi', 'Otomatis tugaskan teknisi berdasarkan workload', _autoAssign, (v) {
                setState(() { _autoAssign = v; _hasChanges = true; });
              }),
              const Divider(),
              _buildSwitch('Persetujuan Admin', 'Tiket perlu disetujui admin sebelum diproses', _requireApproval, (v) {
                setState(() { _requireApproval = v; _hasChanges = true; });
              }),
            ],
          ),

          const SizedBox(height: 16),

          // ── Maintenance Mode ──
          _buildSectionHeader(Icons.build_outlined, 'Mode Maintenance', 'Nonaktifkan sistem sementara'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _maintenanceMode ? const Color(0xFFFEF2F2) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _maintenanceMode ? Colors.red.shade300 : const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: _maintenanceMode ? Colors.red : AppPalette.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mode Maintenance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(
                            _maintenanceMode
                                ? 'Sistem sedang dalam maintenance. User tidak dapat mengakses.'
                                : 'Aktifkan untuk menonaktifkan akses user sementara',
                            style: TextStyle(fontSize: 11, color: _maintenanceMode ? Colors.red : AppPalette.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _maintenanceMode,
                      activeColor: Colors.red,
                      onChanged: (v) {
                        if (v) {
                          _konfirmasiMaintenance();
                        } else {
                          setState(() { _maintenanceMode = false; _hasChanges = true; });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          if (_hasChanges)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simpanPengaturan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Semua Perubahan',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppPalette.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSlaSetting(String label, int jam, ValueChanged<int> onChanged, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: jam > 1 ? () => onChanged(jam - 1) : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${jam}j', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => onChanged(jam + 1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppPalette.primary),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          DropdownButton<String>(
            value: value,
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: onChanged,
            underline: const SizedBox.shrink(),
            isDense: true,
          ),
        ],
      ),
    );
  }

  void _konfirmasiMaintenance() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aktifkan Maintenance?'),
        content: const Text('User tidak akan bisa mengakses sistem selama maintenance aktif. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              setState(() { _maintenanceMode = true; _hasChanges = true; });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Aktifkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _simpanPengaturan() {
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil disimpan'),
        backgroundColor: Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
