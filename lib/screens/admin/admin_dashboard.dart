import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../models/notification_model.dart';
import '../../services/data_service.dart';
import 'admin_semua_tiket_page.dart';
import 'admin_kelola_teknisi_page.dart';
import 'admin_notifikasi_page.dart';
import 'admin_profil_page.dart';
import 'widgets/admin_ticket_detail_page.dart';

class _AppColors {
  static const primary = AppPalette.primary;
  // Removed unused fields: secondary, error, onSurface, onSurfaceVariant, surfaceContainer, outlineVariant
  static const background = AppPalette.backgroundAlt;
}

// ==================== DASHBOARD SHELL ====================
class AdminDashboard extends StatefulWidget {
  final User user;
  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    _HomePage(
      user: widget.user,
      onNavigate: (index) => setState(() => _selectedIndex = index),
    ),
    const AdminSemuaTiketPage(),
    const AdminKelolaTeknisiPage(),
    const AdminNotifikasiPage(),
    AdminProfilPage(user: widget.user),
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
            BoxShadow(blurRadius: 15, color: Colors.black.withOpacity(0.05)),
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
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'Semua Tiket',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.engineering_outlined),
              activeIcon: Icon(Icons.engineering),
              label: 'Teknisi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
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
  final User user;
  final void Function(int) onNavigate;

  const _HomePage({required this.user, required this.onNavigate});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  late List<Ticket> _tickets;

  @override
  void initState() {
    super.initState();
    _tickets = DataService.getAdminSampleTickets();
    DataService.ticketNotifier.addListener(_refresh);
  }

  @override
  void dispose() {
    DataService.ticketNotifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() => _tickets = DataService.getAdminSampleTickets());
  }

  int get _totalTickets => _tickets.length;
  int get _openTickets => _tickets.where((t) => t.status == 'Terbuka').length;
  int get _inProgressTickets => _tickets
      .where((t) => t.status == 'Diproses' || t.status == 'Dikerjakan')
      .length;
  int get _doneTickets => _tickets.where((t) => t.status == 'Selesai').length;
  int get _overdueTickets => _tickets.where((t) => t.isOverdue).length;

  List<Ticket> get _recentTickets => _tickets.take(5).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildStatCards()),
            SliverToBoxAdapter(child: _buildSLAAlert()),
            SliverToBoxAdapter(child: _buildRecentTickets()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: AppPalette.heroGradient),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<List<AppNotification>>(
                valueListenable: DataService.notificationsListenable,
                builder: (_, notifs, _) {
                  final unread = notifs.where((n) => !n.isRead).length;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () => widget.onNavigate(3),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeaderStat('Total Tiket', '$_totalTickets', Icons.inbox),
              const SizedBox(width: 12),
              _buildHeaderStat('Terbuka', '$_openTickets', Icons.fiber_new),
              const SizedBox(width: 12),
              _buildHeaderStat('Overdue', '$_overdueTickets', Icons.warning_amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Status',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Terbuka',
                  count: _openTickets,
                  icon: Icons.inbox_outlined,
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Diproses',
                  count: _inProgressTickets,
                  icon: Icons.sync_outlined,
                  color: const Color(0xFFD97706),
                  bg: const Color(0xFFFFFBEB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Selesai',
                  count: _doneTickets,
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Overdue',
                  count: _overdueTickets,
                  icon: Icons.timer_off_outlined,
                  color: const Color(0xFFDC2626),
                  bg: const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSLAAlert() {
    final urgentTickets = _tickets
        .where((t) => t.slaStatus == 'Urgent' || t.slaStatus == 'Overdue')
        .toList();
    if (urgentTickets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          border: Border.all(color: const Color(0xFFFCA5A5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFDC2626),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${urgentTickets.length} tiket memerlukan perhatian segera (SLA kritis/overdue).',
                style: const TextStyle(
                  color: Color(0xFF7F1D1D),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => widget.onNavigate(1),
              child: const Text('Lihat', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTickets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiket Terbaru',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigate(1),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 12, color: AppPalette.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._recentTickets.map((ticket) => _buildTicketRow(ticket)),
        ],
      ),
    );
  }

  Widget _buildTicketRow(Ticket ticket) {
    Color priorityColor;
    switch (ticket.priority) {
      case 'Urgent':
        priorityColor = const Color(0xFFDC2626);
        break;
      case 'High':
        priorityColor = const Color(0xFFD97706);
        break;
      case 'Medium':
        priorityColor = const Color(0xFF2563EB);
        break;
      default:
        priorityColor = Colors.grey;
    }

    Color statusColor;
    switch (ticket.status) {
      case 'Terbuka':
        statusColor = const Color(0xFF2563EB);
        break;
      case 'Diproses':
      case 'Dikerjakan':
        statusColor = const Color(0xFFD97706);
        break;
      case 'Selesai':
        statusColor = const Color(0xFF059669);
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        DataService.ensureTicketLoaded(ticket);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminTicketDetailPage(ticket: ticket),
          ),
        ).then((_) => _refresh());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
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
                      color: AppPalette.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        ticket.id,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppPalette.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${ticket.reporter}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                ticket.status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== STAT CARD ====================
class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}