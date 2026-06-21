import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'teknisi_tiket_saya_page.dart';
import 'teknisi_notifikasi_page.dart';
import 'teknisi_profil_page.dart';
import 'widgets/teknisi_ticket_detail_page.dart';

class _AppColors {
  static const primary = AppPalette.primary;
  static const secondary = AppPalette.secondary;
  static const tertiary = AppPalette.tertiary;
  static const error = AppPalette.error;
  static const onSurface = AppPalette.textOnSurface;
  static const onSurfaceVariant = AppPalette.textOnSurfaceVariant;
  static const background = AppPalette.backgroundAlt;
  static const surfaceContainer = AppPalette.surfaceContainerLow;
  static const outlineVariant = AppPalette.outlineVariant;
}

// ==================== DASHBOARD SHELL ====================
class TeknisiDashboard extends StatefulWidget {
  final User user;

  const TeknisiDashboard({super.key, required this.user});

  @override
  State<TeknisiDashboard> createState() => _TeknisiDashboardState();
}

class _TeknisiDashboardState extends State<TeknisiDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    _HomePage(
      userName: widget.user.name,
      onNavigate: (index) => setState(() => _selectedIndex = index),
    ),
    const TeknisiTiketSayaPage(),
    const TeknisiNotifikasiPage(),
    TeknisiProfilPage(user: widget.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: _AppColors.primary,
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'Tiket',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HOME PAGE ====================
class _HomePage extends StatefulWidget {
  final String userName;
  final ValueChanged<int> onNavigate;

  const _HomePage({required this.userName, required this.onNavigate});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get _greetingEmoji {
    final hour = DateTime.now().hour;
    if (hour < 11) return '☀️';
    if (hour < 15) return '🌤️';
    if (hour < 18) return '🌇';
    return '🌙';
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'kritis':
        return _AppColors.error;
      case 'high':
      case 'tinggi':
        return _AppColors.tertiary;
      case 'medium':
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return _AppColors.secondary;
    }
  }

  Color _statusColor(String status) {
    if (status == 'Selesai') return Colors.green.shade700;
    if (status == 'Dikerjakan') return Colors.orange.shade700;
    if (status == 'Terbuka') return _AppColors.primary;
    return _AppColors.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataService.ticketNotifier,
      builder: (context, _) {
        final allTickets = DataService.getTeknisiSampleTickets();
        final assignedTickets = allTickets
            .where((t) => t.assignedTo == widget.userName)
            .toList();

        final totalToday = assignedTickets.length;
        final open = assignedTickets.where((t) => t.status == 'Terbuka').length;
        final inProgress =
            assignedTickets.where((t) => t.status == 'Dikerjakan').length;
        final overdue = assignedTickets
            .where((t) => t.priority == 'Urgent' || t.priority == 'Kritis')
            .length;

        final notifCount = overdue;

        return Scaffold(
          backgroundColor: _AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white.withOpacity(0.95),
            surfaceTintColor: Colors.transparent,
            titleSpacing: 16,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFDDE1FF),
                  child: Text(
                    widget.userName[0],
                    style: const TextStyle(
                      color: _AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Dashboard Teknisi',
                  style: TextStyle(
                    color: _AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => widget.onNavigate(2),
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: _AppColors.primary,
                    ),
                  ),
                  if (notifCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: _AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            notifCount > 9 ? '9+' : notifCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () async {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: _AppColors.primary),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── GREETING DINAMIS ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_greetingEmoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$_greeting, ${widget.userName.split(' ').first}!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Berikut ringkasan operasional Anda hari ini.',
                  style: TextStyle(
                    color: _AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),

                // ── BANNER URGENT ──
                if (overdue > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: _AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$overdue tiket Urgent/Kritis membutuhkan perhatian segera!',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _AppColors.error,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _TicketListPage(
                                title: 'Tiket Lewat Batas',
                                tickets: assignedTickets
                                    .where(
                                      (t) =>
                                          t.priority == 'Urgent' ||
                                          t.priority == 'Kritis',
                                    )
                                    .toList(),
                                accentColor: _AppColors.error,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Lihat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _AppColors.error,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ── LABEL SECTION ──
                const Text(
                  'Ringkasan Tiket',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // ── SUMMARY GRID ──
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.45,
                  children: [
                    _DashboardCard(
                      icon: Icons.assessment_outlined,
                      value: totalToday.toString(),
                      label: 'Total Hari Ini',
                      description:
                          'Semua tiket yang sudah ditugaskan kepada Anda.',
                      color: _AppColors.primary,
                      onTap: () => widget.onNavigate(1),
                    ),
                    _DashboardCard(
                      icon: Icons.pending_outlined,
                      value: open.toString(),
                      label: 'Terbuka',
                      description: 'Tiket baru yang belum mulai dikerjakan.',
                      color: _AppColors.secondary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _TicketListPage(
                            title: 'Tiket Terbuka',
                            tickets: assignedTickets
                                .where((t) => t.status == 'Terbuka')
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    _DashboardCard(
                      icon: Icons.sync,
                      value: inProgress.toString(),
                      label: 'Sedang Dikerjakan',
                      description:
                          'Tiket yang sedang dalam proses penanganan.',
                      color: Colors.indigo,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _TicketListPage(
                            title: 'Tiket Dikerjakan',
                            tickets: assignedTickets
                                .where((t) => t.status == 'Dikerjakan')
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    _DashboardCard(
                      icon: Icons.warning_amber_outlined,
                      value: overdue.toString(),
                      label: 'Lewat Batas',
                      description:
                          'Tiket prioritas Urgent/Kritis yang membutuhkan perhatian segera.',
                      color: _AppColors.error,
                      isError: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _TicketListPage(
                            title: 'Tiket Lewat Batas',
                            tickets: assignedTickets
                                .where(
                                  (t) =>
                                      t.priority == 'Urgent' ||
                                      t.priority == 'Kritis',
                                )
                                .toList(),
                            accentColor: _AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── SLA CARD ──
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const _SlaDetailPage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Performa SLA',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Text(
                                  'Target: 98%',
                                  style: TextStyle(
                                    color: _AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Waktu respons Anda masuk dalam 5% terbaik tim.',
                                style: TextStyle(
                                  color: _AppColors.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Row(
                                children: [
                                  Text(
                                    'Lihat Detail',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: _AppColors.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value: 0.95,
                                  strokeWidth: 10,
                                  backgroundColor: _AppColors.surfaceContainer,
                                  color: _AppColors.primary,
                                ),
                              ),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '95%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: _AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    'SLA',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── ACTIVE QUEUE CARD ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.queue,
                              color: _AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Antrian Aktif',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tiket belum diassign menunggu review',
                                  style: TextStyle(
                                    color: _AppColors.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            open.toString(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: _AppColors.primary,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tiket sedang menunggu penugasan teknisi.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => widget.onNavigate(1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Buka Antrian',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── RECENT ACTIVITY ──
                if (assignedTickets.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Aktivitas Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _AppColors.onSurface,
                        ),
                      ),
                      if (assignedTickets.length > 3)
                        GestureDetector(
                          onTap: () => widget.onNavigate(1),
                          child: const Text(
                            'Lihat semua',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...assignedTickets.take(3).map((ticket) {
                    final color = _priorityColor(ticket.priority);
                    final statusColor = _statusColor(ticket.status);

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TeknisiTicketDetailPage(ticket: ticket),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border(left: BorderSide(color: color, width: 4)),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.04),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                ticket.priority == 'Urgent' ||
                                        ticket.priority == 'Kritis'
                                    ? Icons.warning_amber_rounded
                                    : Icons.confirmation_number_outlined,
                                color: color,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticket.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _AppColors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 11,
                                        color: _AppColors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        ticket.reporter,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: _AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 11,
                                        color: _AppColors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        ticket.date,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: _AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                ticket.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =====================================================================
//  DASHBOARD CARD WIDGET
// =====================================================================
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String description;
  final Color color;
  final bool isError;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isError ? const Color(0xFFFFDAD6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _AppColors.outlineVariant.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.04),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isError ? _AppColors.error : _AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 11,
                color: _AppColors.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
//  HALAMAN LIST TIKET
// =====================================================================
class _TicketListPage extends StatelessWidget {
  final String title;
  final List<Ticket> tickets;
  final Color accentColor;

  const _TicketListPage({
    required this.title,
    required this.tickets,
    this.accentColor = _AppColors.primary,
  });

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'urgent':
      case 'kritis':
        return _AppColors.error;
      case 'high':
      case 'tinggi':
        return _AppColors.tertiary;
      case 'medium':
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return _AppColors.onSurfaceVariant;
    }
  }

  Color _statusColor(String s) {
    if (s == 'Selesai') return Colors.green.shade700;
    if (s == 'Dikerjakan') return Colors.orange.shade700;
    if (s == 'Terbuka') return _AppColors.primary;
    return _AppColors.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _AppColors.onSurface,
              ),
            ),
            Text(
              '${tickets.length} tiket',
              style: const TextStyle(
                fontSize: 12,
                color: _AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: _AppColors.outlineVariant.withOpacity(0.4),
          ),
        ),
      ),
      body: tickets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: _AppColors.onSurfaceVariant.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada tiket',
                    style: TextStyle(
                      fontSize: 16,
                      color: _AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, i) {
                final ticket = tickets[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeknisiTicketDetailPage(ticket: ticket),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(
                        left: BorderSide(
                          color: _priorityColor(ticket.priority),
                          width: 4,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _priorityColor(
                                    ticket.priority,
                                  ).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 3,
                                      backgroundColor:
                                          _priorityColor(ticket.priority),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ticket.priority.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _priorityColor(ticket.priority),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    ticket.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  ticket.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor(ticket.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _AppColors.onSurface,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 13,
                                color: _AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ticket.reporter,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: _AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ticket.date,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 11,
                                color: _AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// =====================================================================
//  HALAMAN DETAIL SLA
// =====================================================================
class _SlaDetailPage extends StatelessWidget {
  const _SlaDetailPage();

  @override
  Widget build(BuildContext context) {
    final metrics = [
      const _SlaMetric(
        label: 'Response Time',
        value: '12 menit',
        target: '< 30 menit',
        isGood: true,
      ),
      const _SlaMetric(
        label: 'Resolution Time',
        value: '4.2 jam',
        target: '< 8 jam',
        isGood: true,
      ),
      const _SlaMetric(
        label: 'First Contact Resolution',
        value: '87%',
        target: '> 80%',
        isGood: true,
      ),
      const _SlaMetric(
        label: 'Escalation Rate',
        value: '8%',
        target: '< 5%',
        isGood: false,
      ),
      const _SlaMetric(
        label: 'Customer Satisfaction',
        value: '4.6/5',
        target: '> 4.0',
        isGood: true,
      ),
    ];

    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Performa SLA',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _AppColors.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: _AppColors.outlineVariant.withOpacity(0.4),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Skor SLA Keseluruhan',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: 0.95,
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          color: Colors.white,
                        ),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '95%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'SLA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'Target: 98% • Top 5% Tim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Metrics list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.04),
                  ),
                ],
              ),
              child: Column(
                children: metrics.asMap().entries.map((e) {
                  final isLast = e.key == metrics.length - 1;
                  final m = e.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.label,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Target: ${m.target}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: m.isGood
                                    ? Colors.green.shade50
                                    : _AppColors.error.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                m.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: m.isGood
                                      ? Colors.green.shade700
                                      : _AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          color: _AppColors.outlineVariant,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Escalation rate Anda sedikit di atas target. Coba selesaikan tiket prioritas Medium lebih cepat untuk menurunkan angka ini.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade800,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlaMetric {
  final String label;
  final String value;
  final String target;
  final bool isGood;

  const _SlaMetric({
    required this.label,
    required this.value,
    required this.target,
    required this.isGood,
  });
}