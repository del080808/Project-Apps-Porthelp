import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_model.dart';
import '../../../services/data_service.dart';
import '../pelapor_tiket_saya_page.dart';
import '../pelapor_profil_page.dart';
import '../pelapor_detail_tiket_page.dart';
import '../pelapor_notifikasi_page.dart';
import '../buat_tiket_page.dart';
import '../widgets/pelapor_ticket_card.dart';

class PelaporDashboard extends StatefulWidget {
  final User user;

  const PelaporDashboard({super.key, required this.user});

  @override
  State<PelaporDashboard> createState() => _PelaporDashboardState();
}

class _PelaporDashboardState extends State<PelaporDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    _HomePage(
      userName: widget.user.name,
      onCreateTicket: () => setState(() => _selectedIndex = 2),
      onGoToTickets: () => setState(() => _selectedIndex = 1),
    ),
    const PelaporTiketSayaPage(),
    BuatTiketPage(onSelesai: () => setState(() => _selectedIndex = 0)),
    const PelaporNotifikasiPage(),
    PelaporProfilPage(user: widget.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: DataService.notificationsListenable,
        builder: (context, notifications, child) {
          final unreadCount = notifications.where((n) => !n.isRead).length;
          final hasUnread = unreadCount > 0;

          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppPalette.primary,
            unselectedItemColor: AppPalette.textSecondary,
            backgroundColor: AppPalette.surface,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Beranda',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number),
                label: 'Tiket Saya',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: 'Buat Tiket',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: hasUnread,
                  child: const Icon(Icons.notifications_outlined),
                ),
                label: 'Notifikasi',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================== HOME PAGE ====================
class _HomePage extends StatefulWidget {
  final String userName;
  final VoidCallback onCreateTicket;
  final VoidCallback onGoToTickets;

  const _HomePage({
    required this.userName,
    required this.onCreateTicket,
    required this.onGoToTickets,
  });

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String _selectedFilter = 'Semua';

  // ──────────────────────────────────────────────────
  // PERBAIKAN 4: Pull-to-refresh
  // Method ini dipanggil saat user tarik layar ke bawah.
  // Ganti isi dengan pemanggilan API nyata saat production.
  // ──────────────────────────────────────────────────
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userTickets = DataService.getPelaporSampleTickets();

    final filteredTickets = _selectedFilter == 'Semua'
        ? userTickets
        : userTickets
              .where(
                (t) => t.status.toLowerCase().contains(
                  _selectedFilter.toLowerCase(),
                ),
              )
              .toList();

    final totalTickets = userTickets.length;
    final openTickets = userTickets.where((t) => t.status == 'Terbuka').length;
    final inWorkTickets = userTickets
        .where((t) => t.status == 'Dikerjakan')
        .length;
    final completedTickets = userTickets
        .where((t) => t.status == 'Selesai')
        .length;

    // ──────────────────────────────────────────────────
    // PERBAIKAN 2: Logika "Butuh Perhatian" diperketat.
    // Sebelum : status == 'Terbuka' ATAU ada komentar & belum selesai
    //           → hampir semua tiket aktif masuk, terasa spam.
    // Sesudah : hanya tiket yang komentar TERAKHIRNYA dari teknisi
    //           (artinya teknisi sudah balas tapi pelapor belum respons).
    // ──────────────────────────────────────────────────
    final needAttentionTickets = userTickets
        .where(
          (t) =>
              t.status != 'Selesai' &&
              t.comments.isNotEmpty &&
              t.comments.last.startsWith('Teknisi:'),
        )
        .toList();

    final recentActivities = DataService.getRecentActivities();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard Pelapor'),
        centerTitle: true,
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ──────────────────────────────────────────────────
      // PERBAIKAN 4: Wrap body dengan RefreshIndicator.
      // User bisa tarik layar ke bawah untuk refresh data.
      // ──────────────────────────────────────────────────
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppPalette.primary,
        child: SingleChildScrollView(
          // physics wajib ada agar RefreshIndicator bisa aktif
          // meskipun konten lebih pendek dari layar
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome Card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppPalette.heroGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${widget.userName}! 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ada yang bisa kami bantu hari ini?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: widget.onCreateTicket,
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Tiket Baru'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppPalette.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Statistik Tiket Saya ──
              Text(
                'Statistik Tiket Saya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // ──────────────────────────────────────────────────
              // PERBAIKAN 1: Tambah hint kecil agar user tahu kartu bisa diklik
              // ──────────────────────────────────────────────────
              Text(
                'Ketuk kartu untuk melihat tiket',
                style: TextStyle(
                  fontSize: 11,
                  color: AppPalette.textSecondary.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // ──────────────────────────────────────────────────
                  // PERBAIKAN 1: onTap ditambahkan ke semua _SimpleStatCard.
                  // Semua mengarah ke tab Tiket Saya via widget.onGoToTickets.
                  // ──────────────────────────────────────────────────
                  Expanded(
                    child: _SimpleStatCard(
                      title: 'Total Tiket',
                      value: totalTickets.toString(),
                      icon: Icons.confirmation_number,
                      color: AppPalette.secondary,
                      subtitle: 'Semua tiket Anda',
                      onTap: widget.onGoToTickets,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SimpleStatCard(
                      title: 'Terbuka',
                      value: openTickets.toString(),
                      icon: Icons.lock_open,
                      color: const Color(0xFFF59E0B),
                      subtitle: 'Menunggu ditangani',
                      onTap: widget.onGoToTickets,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SimpleStatCard(
                      title: 'Dikerjakan',
                      value: inWorkTickets.toString(),
                      icon: Icons.engineering,
                      color: AppPalette.secondary,
                      subtitle: 'Sedang diproses teknisi',
                      onTap: widget.onGoToTickets,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SimpleStatCard(
                      title: 'Selesai',
                      value: completedTickets.toString(),
                      icon: Icons.check_circle,
                      color: const Color(0xFF16A34A),
                      subtitle: 'Telah diselesaikan',
                      onTap: widget.onGoToTickets,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Butuh Perhatian Anda ──
              Text(
                'Butuh Perhatian Anda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (needAttentionTickets.isNotEmpty)
                ...needAttentionTickets.map(
                  (ticket) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.warning_amber,
                            color: Color(0xFFB91C1C),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.id,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppPalette.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // ──────────────────────────────────────────────────
                              // PERBAIKAN 2: Teks deskripsi disesuaikan dengan
                              // logika baru — selalu menampilkan "ada komentar baru
                              // dari teknisi" karena kondisi sudah pasti begitu.
                              // ──────────────────────────────────────────────────
                              Text(
                                'Teknisi memberi komentar baru pada "${ticket.title}"',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppPalette.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PelaporDetailTiketPage(ticket: ticket),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppPalette.primary,
                          ),
                          child: const Text('Lihat Detail'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade400,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tidak ada tiket yang membutuhkan tindakan saat ini.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // ── Aktivitas Terbaru ──
              Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...recentActivities.map(
                (activity) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        activity['icon'] as IconData,
                        size: 20,
                        color: AppPalette.secondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['text'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppPalette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activity['time'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppPalette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Tiket Terbaru ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiket Terbaru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  // ──────────────────────────────────────────────────
                  // PERBAIKAN 3: Tombol "Lihat Semua" dibuat lebih
                  // prominent dengan panah dan style yang lebih bold.
                  // ──────────────────────────────────────────────────
                  TextButton(
                    onPressed: widget.onGoToTickets,
                    style: TextButton.styleFrom(
                      foregroundColor: AppPalette.primary,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    child: const Text('Lihat Semua →'),
                  ),
                ],
              ),

              // ──────────────────────────────────────────────────
              // PERBAIKAN 3: Label "Menampilkan X dari Y tiket"
              // hanya muncul kalau tiket memang lebih dari 3,
              // jadi tidak noise kalau tiket sedikit.
              // ──────────────────────────────────────────────────
              if (filteredTickets.length > 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Menampilkan 3 dari ${filteredTickets.length} tiket',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppPalette.textSecondary.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // ── Filter Buttons ──
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['Semua', 'Terbuka', 'Dikerjakan', 'Selesai'].map((
                    filter,
                  ) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = filter),
                        backgroundColor: AppPalette.mutedSurface,
                        selectedColor: AppPalette.secondary.withValues(
                          alpha: 0.16,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppPalette.primary
                              : AppPalette.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTickets.take(3).length,
                itemBuilder: (context, index) {
                  final ticket = filteredTickets[index];
                  return PelaporTicketCard(
                    ticket: ticket,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PelaporDetailTiketPage(ticket: ticket),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== SIMPLE STAT CARD ====================
class _SimpleStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  // ──────────────────────────────────────────────────
  // PERBAIKAN 1: Tambah parameter onTap (nullable).
  // Kalau tidak diisi, kartu tetap tampil normal tanpa aksi.
  // ──────────────────────────────────────────────────
  final VoidCallback? onTap;

  const _SimpleStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.onTap, // ← opsional, tidak breaking perubahan lama
  });

  @override
  Widget build(BuildContext context) {
    // ──────────────────────────────────────────────────
    // PERBAIKAN 1: Wrap Container dengan InkWell agar
    // ada ripple effect saat diklik (lebih native Flutter
    // dibanding GestureDetector yang tidak ada ripple).
    // ──────────────────────────────────────────────────
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPalette.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppPalette.textSecondary,
                    ),
                  ),
                ),
                // ──────────────────────────────────────────────────
                // PERBAIKAN 1: Tampilkan ikon panah kecil kalau
                // kartu bisa diklik, sebagai visual hint untuk user.
                // ──────────────────────────────────────────────────
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: AppPalette.textSecondary.withOpacity(0.5),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
