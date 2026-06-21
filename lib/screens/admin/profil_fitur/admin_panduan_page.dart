import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminPanduanPage extends StatefulWidget {
  const AdminPanduanPage({super.key});

  @override
  State<AdminPanduanPage> createState() => _AdminPanduanPageState();
}

class _AdminPanduanPageState extends State<AdminPanduanPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedTopic;

  final List<Map<String, dynamic>> _topics = [
    {
      'icon': Icons.dashboard_outlined,
      'title': 'Dashboard & Beranda',
      'color': AppPalette.primary,
      'articles': [
        {
          'judul': 'Cara membaca ringkasan statistik',
          'isi': 'Dashboard beranda menampilkan 4 kartu statistik utama:\n\n'
              '• **Terbuka** – Tiket yang belum ditugaskan ke teknisi\n'
              '• **Diproses** – Tiket yang sedang dikerjakan teknisi\n'
              '• **Selesai** – Tiket yang sudah berhasil diselesaikan\n'
              '• **Overdue** – Tiket yang melewati batas SLA\n\n'
              'Klik "Lihat Semua" untuk membuka halaman daftar tiket lengkap.',
        },
        {
          'judul': 'Alert SLA kritis',
          'isi': 'Banner merah di beranda muncul otomatis saat ada tiket dengan status SLA "Urgent" atau "Overdue".\n\n'
              'Klik tombol "Lihat" untuk langsung melihat tiket-tiket tersebut dan segera ambil tindakan.',
        },
        {
          'judul': 'Notifikasi badge di header',
          'isi': 'Ikon lonceng di kanan atas menampilkan jumlah notifikasi yang belum dibaca.\n\n'
              'Klik untuk langsung ke halaman Notifikasi.',
        },
      ],
    },
    {
      'icon': Icons.confirmation_number_outlined,
      'title': 'Manajemen Tiket',
      'color': const Color(0xFF2563EB),
      'articles': [
        {
          'judul': 'Cara menugaskan teknisi ke tiket',
          'isi': 'Ada 2 cara untuk menugaskan teknisi:\n\n'
              '1. Dari halaman "Semua Tiket" → klik tombol "Tugaskan" di bawah kartu tiket\n'
              '2. Dari dalam detail tiket → klik tombol "Tugaskan" di kartu Assignment\n\n'
              'Pilih teknisi dari daftar yang muncul. Status tiket akan otomatis berubah ke "Diproses".',
        },
        {
          'judul': 'Filter dan pencarian tiket',
          'isi': 'Gunakan fitur berikut untuk menemukan tiket:\n\n'
              '• **Search bar** – Cari berdasarkan judul, ID tiket, atau nama pelapor\n'
              '• **Tab filter** – Saring tiket berdasarkan status (Semua/Terbuka/Diproses/Selesai)\n'
              '• **Chip prioritas** – Filter cepat berdasarkan level prioritas',
        },
        {
          'judul': 'Menutup tiket secara manual',
          'isi': 'Admin dapat menutup tiket yang belum selesai:\n\n'
              '1. Buka detail tiket\n'
              '2. Klik ikon ⋮ (titik tiga) di pojok kanan atas\n'
              '3. Pilih "Tutup Tiket"\n'
              '4. Konfirmasi tindakan\n\n'
              'Status tiket akan berubah ke "Selesai" dan dicatat sebagai ditutup oleh admin.',
        },
        {
          'judul': 'Memahami status SLA',
          'isi': 'SLA (Service Level Agreement) adalah batas waktu penanganan tiket:\n\n'
              '🟢 **On Track** – Masih lebih dari 3 hari\n'
              '🟠 **Warning** – Kurang dari 3 hari tersisa\n'
              '🔴 **Urgent** – Kurang dari 1 hari tersisa\n'
              '⛔ **Overdue** – Sudah melewati batas waktu\n\n'
              'Atur batas waktu di Pengaturan → Konfigurasi SLA.',
        },
      ],
    },
    {
      'icon': Icons.engineering_outlined,
      'title': 'Kelola Teknisi',
      'color': const Color(0xFF059669),
      'articles': [
        {
          'judul': 'Memahami status workload teknisi',
          'isi': 'Setiap teknisi memiliki status beban kerja:\n\n'
              '🟢 **Ringan** – 1-2 tiket aktif\n'
              '🟠 **Sedang** – 3-4 tiket aktif\n'
              '🔴 **Overload** – 5+ tiket aktif\n\n'
              'Perhatikan status ini sebelum menugaskan tiket baru agar distribusi kerja merata.',
        },
        {
          'judul': 'Melihat detail teknisi',
          'isi': 'Klik kartu teknisi di halaman "Teknisi" untuk melihat:\n\n'
              '• Informasi kontak (email, telepon)\n'
              '• Divisi dan spesialisasi\n'
              '• Jumlah tiket aktif\n'
              '• Daftar keahlian (skills)',
        },
      ],
    },
    {
      'icon': Icons.people_outline,
      'title': 'Manajemen User',
      'color': const Color(0xFF5B21B6),
      'articles': [
        {
          'judul': 'Menambah user baru',
          'isi': 'Untuk menambah user baru:\n\n'
              '1. Buka Profil → Manajemen User\n'
              '2. Klik ikon "+" di kanan atas\n'
              '3. Isi form: Nama, Email, Telepon, Divisi\n'
              '4. Pilih Role: Pelapor / Teknisi / Admin\n'
              '5. Klik "Tambah"\n\n'
              'User baru langsung aktif dan bisa login.',
        },
        {
          'judul': 'Menonaktifkan akun user',
          'isi': 'User yang sudah tidak aktif sebaiknya dinonaktifkan (bukan dihapus) agar riwayat tiketnya tetap tersimpan:\n\n'
              '1. Buka kartu user → klik ⋮\n'
              '2. Pilih "Nonaktifkan"\n\n'
              'User yang dinonaktifkan tidak bisa login tapi datanya tetap ada.',
        },
        {
          'judul': 'Reset password user',
          'isi': 'Jika user lupa password:\n\n'
              '1. Buka kartu user → klik ⋮\n'
              '2. Pilih "Reset Password"\n'
              '3. Link reset akan dikirim ke email user\n\n'
              'Proses ini aman dan tidak membutuhkan password lama.',
        },
      ],
    },
    {
      'icon': Icons.bar_chart_outlined,
      'title': 'Laporan & Statistik',
      'color': const Color(0xFFD97706),
      'articles': [
        {
          'judul': 'Membaca laporan ringkasan',
          'isi': 'Tab "Ringkasan" menampilkan:\n\n'
              '• KPI utama: total tiket, selesai, overdue, rata-rata rating\n'
              '• Progress bar tingkat penyelesaian\n'
              '• Distribusi status SLA\n\n'
              'Gunakan filter periode (Hari Ini / 7 Hari / 30 Hari / Semua) untuk membandingkan data.',
        },
        {
          'judul': 'Laporan per teknisi',
          'isi': 'Tab "Per Teknisi" menampilkan performa masing-masing teknisi:\n\n'
              '• Total tiket ditangani\n'
              '• Jumlah tiket selesai vs aktif\n'
              '• Tiket overdue\n'
              '• Rating rata-rata dari pelapor\n'
              '• Progress bar persentase penyelesaian',
        },
      ],
    },
    {
      'icon': Icons.download_outlined,
      'title': 'Backup & Ekspor',
      'color': const Color(0xFF0891B2),
      'articles': [
        {
          'judul': 'Cara ekspor data tiket',
          'isi': 'Untuk mengekspor data:\n\n'
              '1. Buka Profil → Backup Data\n'
              '2. Pilih format: CSV atau JSON\n'
              '3. Pilih jenis data yang ingin diekspor\n'
              '4. Klik tombol ekspor dan tunggu prosesnya\n\n'
              'File akan tersimpan ke penyimpanan perangkat.',
        },
        {
          'judul': 'Mengatur backup otomatis',
          'isi': 'Backup otomatis melindungi data dari kehilangan:\n\n'
              '1. Aktifkan toggle "Backup Otomatis"\n'
              '2. Pilih frekuensi: Harian / Mingguan / Bulanan\n\n'
              'Riwayat backup tersimpan di bagian bawah halaman.',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _topics;
    return _topics.where((t) {
      final titleMatch = (t['title'] as String).toLowerCase().contains(_searchQuery);
      final articleMatch = (t['articles'] as List).any(
          (a) => (a['judul'] as String).toLowerCase().contains(_searchQuery));
      return titleMatch || articleMatch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text('Panduan Admin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _selectedTopic != null
          ? _buildTopicDetail()
          : _buildTopicList(),
    );
  }

  Widget _buildTopicList() {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          color: AppPalette.primary.withValues(alpha: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pusat Bantuan Admin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Temukan panduan penggunaan fitur admin', style: TextStyle(fontSize: 12, color: AppPalette.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cari panduan...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppPalette.textSecondary),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppPalette.textSecondary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final topic = _filtered[i];
              final color = topic['color'] as Color;
              final articles = topic['articles'] as List;
              return GestureDetector(
                onTap: () => setState(() => _selectedTopic = topic['title']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(topic['icon'] as IconData, color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(topic['title'] as String,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text('${articles.length} artikel',
                                style: const TextStyle(fontSize: 12, color: AppPalette.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppPalette.textSecondary, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopicDetail() {
    final topic = _topics.firstWhere((t) => t['title'] == _selectedTopic);
    final articles = topic['articles'] as List<Map<String, dynamic>>;
    final color = topic['color'] as Color;

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            leading: GestureDetector(
              onTap: () => setState(() => _selectedTopic = null),
              child: const Icon(Icons.arrow_back, color: AppPalette.primary),
            ),
            title: Text(topic['title'] as String,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            itemBuilder: (_, i) {
              final article = articles[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(Icons.article_outlined, color: color, size: 16),
                  ),
                  title: Text(article['judul'] as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildRichText(article['isi'] as String),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRichText(String text) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('•')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 13, color: AppPalette.primary)),
                Expanded(child: Text(line.substring(2), style: const TextStyle(fontSize: 13, height: 1.5))),
              ],
            ),
          );
        }
        if (line.contains('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: _buildBoldText(line),
          );
        }
        if (line.trim().isEmpty) return const SizedBox(height: 6);
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(line, style: const TextStyle(fontSize: 13, height: 1.5, color: AppPalette.textSecondary)),
        );
      }).toList(),
    );
  }

  Widget _buildBoldText(String line) {
    final parts = line.split('**');
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, height: 1.5, color: AppPalette.textPrimary),
        children: parts.asMap().entries.map((e) {
          final isBold = e.key % 2 == 1;
          return TextSpan(
            text: e.value,
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold, color: AppPalette.primary) : null,
          );
        }).toList(),
      ),
    );
  }
}
