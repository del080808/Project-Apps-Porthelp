import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ticket_model.dart';
import '../../../services/data_service.dart';

class AdminLaporanPage extends StatefulWidget {
  const AdminLaporanPage({super.key});

  @override
  State<AdminLaporanPage> createState() => _AdminLaporanPageState();
}

class _AdminLaporanPageState extends State<AdminLaporanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Ticket> _tickets;
  String _periodFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tickets = DataService.getAdminSampleTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Kalkulasi statistik ──
  int get _total => _tickets.length;
  int get _selesai => _tickets.where((t) => t.status == 'Selesai').length;
  int get _terbuka => _tickets.where((t) => t.status == 'Terbuka').length;
  int get _diproses =>
      _tickets.where((t) => t.status == 'Diproses' || t.status == 'Dikerjakan').length;
  int get _overdue => _tickets.where((t) => t.isOverdue).length;
  double get _persentaseSelesai =>
      _total == 0 ? 0 : (_selesai / _total * 100);

  double get _avgRating {
    final rated = _tickets.where((t) => t.rating != null).toList();
    if (rated.isEmpty) return 0;
    return rated.map((t) => t.rating!).reduce((a, b) => a + b) / rated.length;
  }

  Map<String, int> get _byPriority {
    final map = <String, int>{};
    for (final t in _tickets) {
      map[t.priority] = (map[t.priority] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get _byTeknisi {
    final map = <String, int>{};
    for (final t in _tickets) {
      if (t.assignedTo != null) {
        map[t.assignedTo!] = (map[t.assignedTo!] ?? 0) + 1;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text('Laporan & Statistik',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Per Teknisi'),
            Tab(text: 'Prioritas'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPeriodFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRingkasanTab(),
                _buildTeknisiTab(),
                _buildPrioritasTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    final periods = ['Hari Ini', '7 Hari', '30 Hari', 'Semua'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: periods.map((p) {
          final selected = _periodFilter == p;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppPalette.textPrimary)),
              selected: selected,
              selectedColor: AppPalette.primary,
              backgroundColor: const Color(0xFFF0F3FA),
              side: BorderSide.none,
              onSelected: (_) => setState(() => _periodFilter = p),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRingkasanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          Row(
            children: [
              Expanded(child: _KpiCard(label: 'Total Tiket', value: '$_total', icon: Icons.inbox_outlined, color: AppPalette.primary)),
              const SizedBox(width: 10),
              Expanded(child: _KpiCard(label: 'Selesai', value: '$_selesai', icon: Icons.check_circle_outline, color: const Color(0xFF059669))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _KpiCard(label: 'Overdue', value: '$_overdue', icon: Icons.timer_off_outlined, color: const Color(0xFFDC2626))),
              const SizedBox(width: 10),
              Expanded(child: _KpiCard(label: 'Rata-rata Rating', value: _avgRating > 0 ? '${_avgRating.toStringAsFixed(1)}/5' : '-', icon: Icons.star_outline, color: const Color(0xFFD97706))),
            ],
          ),

          const SizedBox(height: 20),

          // Tingkat Penyelesaian
          _SectionCard(
            title: 'Tingkat Penyelesaian',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Resolusi Rate', style: TextStyle(fontSize: 13)),
                    Text('${_persentaseSelesai.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppPalette.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _persentaseSelesai / 100,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                  ),
                ),
                const SizedBox(height: 16),
                _StatRow(label: 'Terbuka', value: _terbuka, total: _total, color: const Color(0xFF2563EB)),
                _StatRow(label: 'Diproses', value: _diproses, total: _total, color: const Color(0xFFD97706)),
                _StatRow(label: 'Selesai', value: _selesai, total: _total, color: const Color(0xFF059669)),
                _StatRow(label: 'Overdue', value: _overdue, total: _total, color: const Color(0xFFDC2626)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // SLA Overview
          _SectionCard(
            title: 'SLA Overview',
            child: Column(
              children: [
                _SlaRow(
                  label: 'On Track',
                  count: _tickets.where((t) => t.slaStatus == 'On Track').length,
                  color: Colors.green,
                ),
                _SlaRow(
                  label: 'Warning',
                  count: _tickets.where((t) => t.slaStatus == 'Warning').length,
                  color: Colors.orange,
                ),
                _SlaRow(
                  label: 'Urgent',
                  count: _tickets.where((t) => t.slaStatus == 'Urgent').length,
                  color: Colors.red,
                ),
                _SlaRow(
                  label: 'Overdue',
                  count: _tickets.where((t) => t.slaStatus == 'Overdue').length,
                  color: Colors.red.shade900,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeknisiTab() {
    final teknisiData = _byTeknisi;
    if (teknisiData.isEmpty) {
      return const Center(
        child: Text('Belum ada tiket yang ditugaskan', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teknisiData.length,
      itemBuilder: (_, i) {
        final name = teknisiData.keys.elementAt(i);
        final count = teknisiData.values.elementAt(i);
        final selesai = _tickets.where((t) => t.assignedTo == name && t.status == 'Selesai').length;
        final overdue = _tickets.where((t) => t.assignedTo == name && t.isOverdue).length;
        final ratings = _tickets.where((t) => t.assignedTo == name && t.rating != null).map((t) => t.rating!).toList();
        final avgRating = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppPalette.primary.withValues(alpha: 0.1),
                    child: Text(name.substring(0, 1),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppPalette.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('$count tiket ditangani', style: const TextStyle(fontSize: 12, color: AppPalette.textSecondary)),
                      ],
                    ),
                  ),
                  if (avgRating > 0)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFFD97706)),
                        Text(' ${avgRating.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MiniStat(label: 'Total', value: count, color: AppPalette.primary),
                  _MiniStat(label: 'Selesai', value: selesai, color: const Color(0xFF059669)),
                  _MiniStat(label: 'Aktif', value: count - selesai, color: const Color(0xFFD97706)),
                  _MiniStat(label: 'Overdue', value: overdue, color: const Color(0xFFDC2626)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: count == 0 ? 0 : selesai / count,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                ),
              ),
              const SizedBox(height: 4),
              Text('${count == 0 ? 0 : (selesai / count * 100).toStringAsFixed(0)}% diselesaikan',
                  style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrioritasTab() {
    final data = _byPriority;
    final priorities = [
      {'label': 'Urgent', 'color': const Color(0xFFDC2626)},
      {'label': 'High', 'color': const Color(0xFFD97706)},
      {'label': 'Medium', 'color': const Color(0xFF2563EB)},
      {'label': 'Low', 'color': Colors.grey},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SectionCard(
            title: 'Distribusi Prioritas',
            child: Column(
              children: priorities.map((p) {
                final label = p['label'] as String;
                final color = p['color'] as Color;
                final count = data[label] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(label, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          Text('$count tiket (${_total == 0 ? 0 : (count / _total * 100).toStringAsFixed(0)}%)',
                              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _total == 0 ? 0 : count / _total,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          _SectionCard(
            title: 'Tiket per Prioritas',
            child: Column(
              children: priorities.map((p) {
                final label = p['label'] as String;
                final color = p['color'] as Color;
                final tickets = _tickets.where((t) => t.priority == label).toList();
                if (tickets.isEmpty) return const SizedBox.shrink();
                return ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                  ),
                  title: Text('${tickets.length} tiket', style: const TextStyle(fontSize: 13)),
                  children: tickets.map((t) => ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(t.title, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: t.status == 'Selesai' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(t.status, style: TextStyle(fontSize: 10, color: t.status == 'Selesai' ? Colors.green : Colors.orange)),
                    ),
                  )).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ──

class _KpiCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value, total;
  final Color color;
  const _StatRow({required this.label, required this.value, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text('$value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 6),
          Text('(${total == 0 ? 0 : (value / total * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
        ],
      ),
    );
  }
}

class _SlaRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SlaRow({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('$count tiket', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppPalette.textSecondary)),
        ],
      ),
    );
  }
}
