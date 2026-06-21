import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/data_service.dart';

class AdminBackupPage extends StatefulWidget {
  const AdminBackupPage({super.key});

  @override
  State<AdminBackupPage> createState() => _AdminBackupPageState();
}

class _AdminBackupPageState extends State<AdminBackupPage> {
  bool _isExporting = false;
  String? _lastExportTime;

  final List<Map<String, dynamic>> _riwayatBackup = [
    {'tanggal': '29 Mei 2026 - 14:30', 'tipe': 'Otomatis', 'ukuran': '2.3 MB', 'status': 'Berhasil'},
    {'tanggal': '22 Mei 2026 - 09:00', 'tipe': 'Manual', 'ukuran': '1.9 MB', 'status': 'Berhasil'},
    {'tanggal': '15 Mei 2026 - 14:30', 'tipe': 'Otomatis', 'ukuran': '1.7 MB', 'status': 'Berhasil'},
    {'tanggal': '8 Mei 2026 - 14:30', 'tipe': 'Otomatis', 'ukuran': '1.4 MB', 'status': 'Gagal'},
  ];

  bool _autoBackup = true;
  String _frekuensi = 'Mingguan';
  final List<String> _exportFormat = ['CSV', 'JSON'];
  String _selectedFormat = 'CSV';

  @override
  Widget build(BuildContext context) {
    final tickets = DataService.getAdminSampleTickets();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text('Backup & Ekspor Data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Status Backup Terakhir ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_done_outlined, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    const Text('Backup Terakhir',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _lastExportTime ?? '29 Mei 2026, 14:30 WIB',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatChip('${tickets.length} Tiket'),
                    const SizedBox(width: 8),
                    _buildStatChip('${DataService.getSampleTeknisi().length} Teknisi'),
                    const SizedBox(width: 8),
                    _buildStatChip('Semua Data'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Ekspor Manual ──
          _buildSectionCard(
            title: 'Ekspor Data Sekarang',
            icon: Icons.download_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Format ekspor:', style: TextStyle(fontSize: 12, color: AppPalette.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: _exportFormat.map((f) {
                    final selected = _selectedFormat == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFormat = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppPalette.primary : const Color(0xFFF0F3FA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: selected ? AppPalette.primary : const Color(0xFFE5E7EB)),
                          ),
                          child: Text(f,
                              style: TextStyle(fontSize: 13,
                                  color: selected ? Colors.white : AppPalette.textPrimary,
                                  fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _buildExportButton('Semua Tiket', Icons.confirmation_number_outlined, '${tickets.length} records', () => _doExport('Semua Tiket')),
                const SizedBox(height: 10),
                _buildExportButton('Tiket Selesai', Icons.check_circle_outline, '${tickets.where((t) => t.status == 'Selesai').length} records', () => _doExport('Tiket Selesai')),
                const SizedBox(height: 10),
                _buildExportButton('Data Teknisi', Icons.engineering_outlined, '${DataService.getSampleTeknisi().length} records', () => _doExport('Data Teknisi')),
                const SizedBox(height: 10),
                _buildExportButton('Laporan Lengkap', Icons.bar_chart_outlined, 'Semua data', () => _doExport('Laporan Lengkap')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Auto Backup ──
          _buildSectionCard(
            title: 'Pengaturan Backup Otomatis',
            icon: Icons.settings_backup_restore,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Backup Otomatis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text('Simpan data secara berkala', style: TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _autoBackup,
                      onChanged: (v) => setState(() => _autoBackup = v),
                      activeColor: AppPalette.primary,
                    ),
                  ],
                ),
                if (_autoBackup) ...[
                  const Divider(),
                  Row(
                    children: [
                      const Text('Frekuensi:', style: TextStyle(fontSize: 13)),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _frekuensi,
                        underline: const SizedBox.shrink(),
                        items: ['Harian', 'Mingguan', 'Bulanan'].map((f) =>
                            DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) => setState(() => _frekuensi = v!),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Riwayat Backup ──
          _buildSectionCard(
            title: 'Riwayat Backup',
            icon: Icons.history,
            child: Column(
              children: _riwayatBackup.map((r) {
                final berhasil = r['status'] == 'Berhasil';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        berhasil ? Icons.check_circle_outline : Icons.error_outline,
                        color: berhasil ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['tanggal'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            Text('${r['tipe']} · ${r['ukuran']}',
                                style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: berhasil ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(r['status'],
                            style: TextStyle(fontSize: 10, color: berhasil ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppPalette.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon, String info, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isExporting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppPalette.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(info, style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
                ],
              ),
            ),
            Icon(
              _isExporting ? Icons.hourglass_empty : Icons.file_download_outlined,
              size: 18,
              color: AppPalette.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doExport(String type) async {
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(seconds: 2));
    final now = DateTime.now();
    setState(() {
      _isExporting = false;
      _lastExportTime = '${now.day} ${_bulan(now.month)} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ekspor "$type" ($_selectedFormat) berhasil disimpan'),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  String _bulan(int m) {
    const b = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return b[m];
  }
}
