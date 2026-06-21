import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../models/notification_model.dart';
import '../../services/data_service.dart';
import 'widgets/admin_ticket_detail_page.dart';

class AdminSemuaTiketPage extends StatefulWidget {
  const AdminSemuaTiketPage({super.key});

  @override
  State<AdminSemuaTiketPage> createState() => _AdminSemuaTiketPageState();
}

class _AdminSemuaTiketPageState extends State<AdminSemuaTiketPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filterPriority = 'Semua';

  final List<String> _tabs = [
    'Semua',
    'Terbuka',
    'Diproses',
    'Selesai',
  ];

  late List<Ticket> _allTickets;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _allTickets = DataService.getAdminSampleTickets();
    DataService.ticketNotifier.addListener(_refresh);
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    DataService.ticketNotifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() => _allTickets = DataService.getAdminSampleTickets());
  }

  List<Ticket> _filtered(String statusFilter) {
    return _allTickets.where((t) {
      final matchStatus = statusFilter == 'Semua'
          ? true
          : statusFilter == 'Diproses'
              ? t.status == 'Diproses' || t.status == 'Dikerjakan'
              : t.status == statusFilter;
      final matchPriority =
          _filterPriority == 'Semua' ? true : t.priority == _filterPriority;
      final matchSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery) ||
          t.id.toLowerCase().contains(_searchQuery) ||
          t.reporter.toLowerCase().contains(_searchQuery);
      return matchStatus && matchPriority && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilterChips(),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppPalette.primary,
            unselectedLabelColor: AppPalette.textSecondary,
            indicatorColor: AppPalette.primary,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: _tabs.map((t) {
              final count = _filtered(t).length;
              return Tab(text: '$t ($count)');
            }).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildTicketList(tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        gradient: AppPalette.heroGradient,
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          const Text(
            'Semua Tiket',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_allTickets.length} tiket',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Cari tiket, ID, atau pelapor...',
          hintStyle:
              const TextStyle(fontSize: 13, color: AppPalette.textSecondary),
          prefixIcon:
              const Icon(Icons.search, size: 20, color: AppPalette.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _searchCtrl.clear(),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF0F3FA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final priorities = ['Semua', 'Urgent', 'High', 'Medium', 'Low'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: priorities.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final p = priorities[i];
          final selected = _filterPriority == p;
          return ChoiceChip(
            label: Text(p,
                style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : AppPalette.textPrimary)),
            selected: selected,
            selectedColor: AppPalette.primary,
            backgroundColor: const Color(0xFFF0F3FA),
            onSelected: (_) => setState(() => _filterPriority = p),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }

  Widget _buildTicketList(String statusFilter) {
    final tickets = _filtered(statusFilter);
    if (tickets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Tidak ada tiket', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (_, i) => _AdminTicketCard(
        ticket: tickets[i],
        onTap: () async {
          DataService.ensureTicketLoaded(tickets[i]);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminTicketDetailPage(ticket: tickets[i]),
            ),
          );
          _refresh();
        },
        onAssign: () => _showAssignDialog(tickets[i]),
      ),
    );
  }

  void _showAssignDialog(Ticket ticket) {
    final teknisiList = DataService.getSampleTeknisi();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tugaskan Teknisi',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                ticket.title,
                style: const TextStyle(
                    fontSize: 13, color: AppPalette.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 20),
              ...teknisiList.map((tk) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppPalette.primary.withOpacity(0.1),
                      child: Text(
                        tk.name.substring(0, 1),
                        style: const TextStyle(
                            color: AppPalette.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(tk.name,
                        style: const TextStyle(fontSize: 13)),
                    subtitle: Text(tk.specialization,
                        style: const TextStyle(fontSize: 11)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tk.workloadColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tk.workloadStatus,
                        style: TextStyle(
                            fontSize: 10,
                            color: tk.workloadColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
                      DataService.updateTicketStatus(ticket.id, 'Diproses');
                      DataService.addNotification(
                        AppNotification(
                          id: 'N-${DateTime.now().millisecondsSinceEpoch}',
                          type: 'assigned',
                          title: 'Tiket Ditugaskan',
                          message:
                              '${tk.name} ditugaskan ke tiket #${ticket.id}.',
                          time: 'Baru saja',
                          isRead: false,
                          ticketId: ticket.id,
                        ),
                      );
                      Navigator.pop(context);
                      _refresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Tiket berhasil ditugaskan ke ${tk.name}'),
                          backgroundColor: const Color(0xFF059669),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}

// ==================== TICKET CARD ====================
class _AdminTicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;
  final VoidCallback onAssign;

  const _AdminTicketCard({
    required this.ticket,
    required this.onTap,
    required this.onAssign,
  });

  Color get _priorityColor {
    switch (ticket.priority) {
      case 'Urgent':
        return const Color(0xFFDC2626);
      case 'High':
        return const Color(0xFFD97706);
      case 'Medium':
        return const Color(0xFF2563EB);
      default:
        return Colors.grey;
    }
  }

  Color get _statusColor {
    switch (ticket.status) {
      case 'Terbuka':
        return const Color(0xFF2563EB);
      case 'Diproses':
      case 'Dikerjakan':
        return const Color(0xFFD97706);
      case 'Selesai':
        return const Color(0xFF059669);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ticket.priority,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _priorityColor),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ticket.status,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _statusColor),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        ticket.id,
                        style: const TextStyle(
                            fontSize: 11, color: AppPalette.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 13, color: AppPalette.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        ticket.reporter,
                        style: const TextStyle(
                            fontSize: 11, color: AppPalette.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppPalette.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        ticket.date,
                        style: const TextStyle(
                            fontSize: 11, color: AppPalette.textSecondary),
                      ),
                    ],
                  ),
                  if (ticket.assignedTo != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.engineering_outlined,
                            size: 13, color: AppPalette.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Ditugaskan: ${ticket.assignedTo}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppPalette.primary,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // SLA bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: ticket.slaColor.withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14)),
                border: Border(
                  top: BorderSide(
                      color: ticket.slaColor.withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined,
                      size: 13, color: ticket.slaColor),
                  const SizedBox(width: 4),
                  Text(
                    'SLA: ${ticket.slaStatus}',
                    style: TextStyle(
                        fontSize: 11,
                        color: ticket.slaColor,
                        fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (ticket.status == 'Terbuka')
                    GestureDetector(
                      onTap: onAssign,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppPalette.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Tugaskan',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
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