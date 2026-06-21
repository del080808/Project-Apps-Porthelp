import 'package:flutter/material.dart';

import '../../models/ticket_model.dart';
import '../../services/data_service.dart';
import 'widgets/teknisi_ticket_detail_page.dart';
import 'widgets/teknisi_ticket_card.dart';

// ==================== COLOR CONSTANTS ====================
class _AppColors {
  static const primary = Color(0xFF00288E);
  static const secondary = Color(0xFF0060AC);
  static const error = Color(0xFFBA1A1A);
  static const onSurface = Color(0xFF1A1B22);
  static const onSurfaceVariant = Color(0xFF444653);
  static const outline = Color(0xFF757684);
  static const outlineVariant = Color(0xFFC4C5D5);
  static const background = Color(0xFFF3F4F6);
}

// =====================================================================
//  HALAMAN UTAMA: TIKET SAYA
// =====================================================================
class TeknisiTiketSayaPage extends StatefulWidget {
  const TeknisiTiketSayaPage({super.key});

  @override
  State<TeknisiTiketSayaPage> createState() => _TeknisiTiketSayaPageState();
}

class _TeknisiTiketSayaPageState extends State<TeknisiTiketSayaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'Semua';
  String _filterPriority = 'Semua';
  String _filterCategory = 'Semua';
  String _sortBy = 'Terbaru';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  String _getTicketCategory(Ticket ticket) {
    final text = '${ticket.title} ${ticket.description}'.toLowerCase();

    if (text.contains('printer') ||
        text.contains('komputer') ||
        text.contains('laptop') ||
        text.contains('monitor') ||
        text.contains('keyboard') ||
        text.contains('mouse') ||
        text.contains('hardware')) {
      return 'Hardware';
    }

    if (text.contains('internet') ||
        text.contains('koneksi') ||
        text.contains('wifi') ||
        text.contains('jaringan') ||
        text.contains('network')) {
      return 'Jaringan';
    }

    if (text.contains('ac') ||
        text.contains('listrik') ||
        text.contains('lampu') ||
        text.contains('infrastruktur')) {
      return 'Infrastruktur';
    }

    if (text.contains('password') ||
        text.contains('login') ||
        text.contains('akun') ||
        text.contains('access') ||
        text.contains('iam') ||
        text.contains('akses')) {
      return 'Akses & IAM';
    }

    return 'Software';
  }

  bool _matchesCategory(Ticket ticket) {
    if (_filterCategory == 'Semua') return true;
    return _getTicketCategory(ticket) == _filterCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Ticket> _applyFilters(List<Ticket> list) {
    var filtered = list.where((t) {
      final matchSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery) ||
          t.reporter.toLowerCase().contains(_searchQuery) ||
          t.id.toLowerCase().contains(_searchQuery) ||
          t.description.toLowerCase().contains(_searchQuery) ||
          (t.assignedTo?.toLowerCase().contains(_searchQuery) ?? false) ||
          t.status.toLowerCase().contains(_searchQuery) ||
          t.priority.toLowerCase().contains(_searchQuery) ||
          _getTicketCategory(t).toLowerCase().contains(_searchQuery);
      final matchStatus =
          _filterStatus == 'Semua' || t.status == _filterStatus;
      final matchPriority =
          _filterPriority == 'Semua' || t.priority == _filterPriority;
      final matchCategory = _matchesCategory(t);
      return matchSearch && matchStatus && matchPriority && matchCategory;
    }).toList();

    if (_sortBy == 'Prioritas') {
      const order = ['Urgent', 'Kritis', 'Tinggi', 'High', 'Medium', 'Sedang'];
      filtered.sort(
        (a, b) =>
            order.indexOf(a.priority).compareTo(order.indexOf(b.priority)),
      );
    }
    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _filterStatus = 'Semua';
      _filterPriority = 'Semua';
      _filterCategory = 'Semua';
      _sortBy = 'Terbaru';
      _searchController.clear();
    });
  }

  void _showTicketDetail(BuildContext context, Ticket ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeknisiTicketDetailPage(ticket: ticket),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataService.ticketNotifier,
      builder: (context, _) {
        final allTickets = DataService.getTeknisiSampleTickets();

        final unassignedCount =
            allTickets.where((t) => t.assignedTo == null).length;
        final highPrioCount = allTickets
            .where(
              (t) =>
                  t.priority.toLowerCase() == 'urgent' ||
                  t.priority.toLowerCase() == 'kritis' ||
                  t.priority.toLowerCase() == 'high' ||
                  t.priority.toLowerCase() == 'tinggi',
            )
            .length;
        final inProgressCount =
            allTickets.where((t) => t.status == 'Dikerjakan').length;

        return Scaffold(
          backgroundColor: _AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF1E40AF),
                  child: const Icon(
                    Icons.support_agent,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'IT Helpdesk',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.5,
                    color: Color(0xFF00288E),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: _AppColors.primary,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: _AppColors.outlineVariant.withOpacity(0.4),
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _AppColors.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText:
                                'Search tickets, IDs, or employees...',
                            hintStyle: TextStyle(
                              color: _AppColors.outline,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: _AppColors.outline,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Stats Cards
                    SizedBox(
                      height: 88,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _StatCard(
                            label: 'Unassigned',
                            value: unassignedCount
                                .toString()
                                .padLeft(2, '0'),
                            valueColor: _AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: 'High Priority',
                            value:
                                highPrioCount.toString().padLeft(2, '0'),
                            valueColor: _AppColors.error,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: 'In Progress',
                            value: inProgressCount
                                .toString()
                                .padLeft(2, '0'),
                            valueColor: _AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Queue Filters Header
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Queue Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _AppColors.onSurface,
                            ),
                          ),
                          GestureDetector(
                            onTap: _clearFilters,
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  size: 16,
                                  color: _AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Clear All',
                                  style: TextStyle(
                                    color: _AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Filter Dropdowns 2x2
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _FilterDropdown(
                                  label: 'Status',
                                  value: _filterStatus,
                                  items: const [
                                    'Semua',
                                    'Terbuka',
                                    'Dikerjakan',
                                    'Selesai',
                                  ],
                                  onChanged: (v) => setState(
                                    () => _filterStatus = v!,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _FilterDropdown(
                                  label: 'Priority',
                                  value: _filterPriority,
                                  items: const [
                                    'Semua',
                                    'Urgent',
                                    'High',
                                    'Medium',
                                  ],
                                  onChanged: (v) => setState(
                                    () => _filterPriority = v!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _FilterDropdown(
                                  label: 'Category',
                                  value: _filterCategory,
                                  items: const [
                                    'Semua',
                                    'Hardware',
                                    'Software',
                                    'Jaringan',
                                    'Akses & IAM',
                                    'Infrastruktur',
                                  ],
                                  onChanged: (v) => setState(
                                    () => _filterCategory = v!,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _FilterDropdown(
                                  label: 'Sort',
                                  value: _sortBy,
                                  items: const ['Terbaru', 'Prioritas'],
                                  onChanged: (v) =>
                                      setState(() => _sortBy = v!),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              // Ticket List
              _buildTicketSliver(_applyFilters(allTickets), context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketSliver(List<Ticket> ticketList, BuildContext context) {
    if (ticketList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.engineering,
                size: 64,
                color: _AppColors.outline.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada tiket',
                style: TextStyle(
                  fontSize: 16,
                  color: _AppColors.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tiket akan muncul setelah diassign oleh Admin',
                style: TextStyle(fontSize: 13, color: _AppColors.outline),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final unassigned = ticketList.where((t) => t.assignedTo == null).toList();
    final assigned = ticketList.where((t) => t.assignedTo != null).toList();

    final items = <Widget>[
      if (unassigned.isNotEmpty) ...[
        _SectionLabel(
          label: 'Tiket Belum Diassign',
          count: unassigned.length,
          color: _AppColors.error,
        ),
        const SizedBox(height: 10),
        ...unassigned.map(
          (ticket) => TeknisiTicketCard(
            ticket: ticket,
            onTap: () => _showTicketDetail(context, ticket),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: _AppColors.outlineVariant),
        const SizedBox(height: 8),
      ],
      if (assigned.isNotEmpty) ...[
        _SectionLabel(
          label: 'Tiket Sudah Diassign',
          count: assigned.length,
          color: _AppColors.secondary,
        ),
        const SizedBox(height: 10),
        ...assigned.map(
          (ticket) => TeknisiTicketCard(
            ticket: ticket,
            onTap: () => _showTicketDetail(context, ticket),
          ),
        ),
      ],
    ];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => items[index],
          childCount: items.length,
        ),
      ),
    );
  }
}

// =====================================================================
//  REUSABLE QUEUE PAGE WIDGETS
// =====================================================================
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _AppColors.outlineVariant.withOpacity(0.3),
        ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _AppColors.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _AppColors.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: _AppColors.outline,
          ),
          style: const TextStyle(
            fontSize: 13,
            color: _AppColors.onSurfaceVariant,
            fontFamily: 'Inter',
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text('$label: $item'),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SectionLabel({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _AppColors.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}