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
      backgroundColor: AppPalette.background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        elevation: 4,
        backgroundColor: AppPalette.surface,
        selectedItemColor: AppPalette.primary,
        unselectedItemColor: AppPalette.textSecondary,
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
        return AppPalette.error;
      case 'high':
      case 'tinggi':
        return AppPalette.tertiary;
      case 'medium':
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return AppPalette.secondary;
    }
  }

  Color _statusColor(String status) {
    if (status == 'Selesai') return const Color(0xFF16A34A);
    if (status == 'Dikerjakan') return const Color(0xFFF59E0B);
    if (status == 'Terbuka') return AppPalette.primary;
    return AppPalette.textSecondary;
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
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
        final inProgress = assignedTickets
            .where((t) => t.status == 'Dikerjakan')
            .length;
        final overdue = assignedTickets
            .where((t) => t.priority == 'Urgent' || t.priority == 'Kritis')
            .length;

        final notifCount = overdue;

        return Scaffold(
          backgroundColor: AppPalette.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppPalette.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 16,
            title: const Text(
              'Dashboard Teknisi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 20,
              ),
            ),
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => widget.onNavigate(2),
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                  if (notifCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppPalette.error,
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
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppPalette.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── GREETING / WELCOME CARD ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppPalette.heroGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _greetingEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$_greeting, ${widget.userName.split(' ').first}!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Berikut ringkasan operasional Anda hari ini.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── BANNER URGENT ──
                  if (overdue > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppPalette.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppPalette.error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$overdue tiket Urgent/Kritis membutuhkan perhatian segera!',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppPalette.error,
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
                                  accentColor: AppPalette.error,
                                ),
                              ),
                            ),
                            child: Text(
                              'Lihat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.error,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── RINGKASAN TIKET ──
                  Text(
                    'Ringkasan Tiket',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ketuk kartu untuk melihat tiket',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppPalette.textSecondary.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── SUMMARY GRID ──
                  Row(
                    children: [
                      Expanded(
                        child: _DashboardCard(
                          icon: Icons.assessment_outlined,
                          value: totalToday.toString(),
                          label: 'Total Hari Ini',
                          subtitle: 'Semua tiket yang ditugaskan.',
                          color: AppPalette.secondary,
                          onTap: () => widget.onNavigate(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DashboardCard(
                          icon: Icons.lock_open,
                          value: open.toString(),
                          label: 'Terbuka',
                          subtitle: 'Belum mulai dikerjakan.',
                          color: const Color(0xFFF59E0B),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DashboardCard(
                          icon: Icons.engineering,
                          value: inProgress.toString(),
                          label: 'Dikerjakan',
                          subtitle: 'Sedang diproses teknisi.',
                          color: AppPalette.secondary,
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DashboardCard(
                          icon: Icons.warning_amber_outlined,
                          value: overdue.toString(),
                          label: 'Lewat Batas',
                          subtitle: 'Prioritas Urgent/Kritis.',
                          color: AppPalette.error,
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
                                accentColor: AppPalette.error,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── ACTIVE QUEUE CARD ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppPalette.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 2,
                          color: Colors.grey.withValues(alpha: 0.1),
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
                                color: AppPalette.secondary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.queue,
                                color: AppPalette.secondary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Antrian Aktif',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tiket menunggu penugasan',
                                    style: TextStyle(
                                      color: AppPalette.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              open.toString(),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppPalette.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppPalette.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tiket sedang menunggu penugasan teknisi.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppPalette.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onNavigate(1),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Buka Antrian'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
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
                        Text(
                          'Aktivitas Terbaru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                        if (assignedTickets.length > 3)
                          TextButton(
                            onPressed: () => widget.onNavigate(1),
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
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppPalette.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(color: color, width: 4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 5,
                                spreadRadius: 1,
                                color: Colors.grey.withValues(alpha: 0.05),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
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
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppPalette.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 11,
                                          color: AppPalette.textSecondary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          ticket.reporter,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppPalette.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 11,
                                          color: AppPalette.textSecondary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          ticket.date,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppPalette.textSecondary,
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
                                  color: statusColor.withValues(alpha: 0.1),
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
  final String subtitle;
  final Color color;
  final bool isError;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isError ? const Color(0xFFFFEDED) : AppPalette.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 2,
              color: Colors.grey.withValues(alpha: 0.1),
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
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isError
                        ? AppPalette.error
                        : AppPalette.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
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
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: AppPalette.textSecondary.withValues(alpha: 0.5),
                ),
              ],
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
    Color? accentColor,
  }) : accentColor = accentColor ?? AppPalette.primary;

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'urgent':
      case 'kritis':
        return AppPalette.error;
      case 'high':
      case 'tinggi':
        return AppPalette.tertiary;
      case 'medium':
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return AppPalette.textSecondary;
    }
  }

  Color _statusColor(String s) {
    if (s == 'Selesai') return const Color(0xFF16A34A);
    if (s == 'Dikerjakan') return const Color(0xFFF59E0B);
    if (s == 'Terbuka') return AppPalette.primary;
    return AppPalette.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                color: Colors.white,
              ),
            ),
            Text(
              '${tickets.length} tiket',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
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
                    color: AppPalette.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada tiket',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppPalette.textSecondary,
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
                      color: AppPalette.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(
                        left: BorderSide(
                          color: _priorityColor(ticket.priority),
                          width: 4,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
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
                                  ).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 3,
                                      backgroundColor: _priorityColor(
                                        ticket.priority,
                                      ),
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
                                  ).withValues(alpha: 0.1),
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
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 13,
                                color: AppPalette.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ticket.reporter,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppPalette.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: AppPalette.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ticket.date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppPalette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppPalette.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 11,
                                color: AppPalette.primary,
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
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Performa SLA',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score Card – pakai heroGradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppPalette.heroGradient,
                borderRadius: BorderRadius.circular(16),
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
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                      color: Colors.white.withValues(alpha: 0.15),
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
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 2,
                    color: Colors.grey.withValues(alpha: 0.1),
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Target: ${m.target}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppPalette.textSecondary,
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
                                    ? const Color(
                                        0xFF16A34A,
                                      ).withValues(alpha: 0.1)
                                    : AppPalette.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                m.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: m.isGood
                                      ? const Color(0xFF16A34A)
                                      : AppPalette.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: Colors.grey.withValues(alpha: 0.1),
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
            const SizedBox(height: 20),
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
