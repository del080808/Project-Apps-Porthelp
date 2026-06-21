import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/teknisi_model.dart';
import '../../services/data_service.dart';

class AdminKelolaTeknisiPage extends StatefulWidget {
  const AdminKelolaTeknisiPage({super.key});

  @override
  State<AdminKelolaTeknisiPage> createState() => _AdminKelolaTeknisiPageState();
}

class _AdminKelolaTeknisiPageState extends State<AdminKelolaTeknisiPage> {
  late List<Teknisi> _teknisiList;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _teknisiList = DataService.getSampleTeknisi();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Teknisi> get _filtered => _teknisiList.where((t) {
        return _searchQuery.isEmpty ||
            t.name.toLowerCase().contains(_searchQuery) ||
            t.specialization.toLowerCase().contains(_searchQuery) ||
            t.division.toLowerCase().contains(_searchQuery);
      }).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildSummaryRow(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _TeknisiCard(
                teknisi: _filtered[i],
                onDetail: () => _showTeknisiDetail(_filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(gradient: AppPalette.heroGradient),
      child: Row(
        children: [
          const Icon(Icons.engineering, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          const Text(
            'Kelola Teknisi',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_teknisiList.length} teknisi',
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
          hintText: 'Cari teknisi atau divisi...',
          hintStyle:
              const TextStyle(fontSize: 13, color: AppPalette.textSecondary),
          prefixIcon: const Icon(Icons.search,
              size: 20, color: AppPalette.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _searchCtrl.clear(),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF0F3FA),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final ringan =
        _teknisiList.where((t) => t.workloadStatus == 'Ringan').length;
    final sedang =
        _teknisiList.where((t) => t.workloadStatus == 'Sedang').length;
    final overload =
        _teknisiList.where((t) => t.workloadStatus == 'Overload').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _WorkloadChip(label: 'Ringan', count: ringan, color: Colors.green),
          const SizedBox(width: 8),
          _WorkloadChip(label: 'Sedang', count: sedang, color: Colors.orange),
          const SizedBox(width: 8),
          _WorkloadChip(
              label: 'Overload', count: overload, color: Colors.red),
        ],
      ),
    );
  }

  void _showTeknisiDetail(Teknisi teknisi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        AppPalette.primary.withOpacity(0.12),
                    child: Text(
                      teknisi.name.substring(0, 1),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teknisi.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text(teknisi.specialization,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppPalette.textSecondary)),
                        Text(teknisi.division,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppPalette.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: teknisi.workloadColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      teknisi.workloadStatus,
                      style: TextStyle(
                          color: teknisi.workloadColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _detailRow(Icons.email_outlined, 'Email', teknisi.email),
              _detailRow(Icons.phone_outlined, 'Telepon', teknisi.phone),
              _detailRow(Icons.work_outline, 'Divisi', teknisi.division),
              _detailRow(Icons.confirmation_number_outlined,
                  'Tiket Aktif', '${teknisi.activeTickets} tiket'),
              const SizedBox(height: 16),
              const Text('Keahlian',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: teknisi.skills
                    .map((s) => Chip(
                          label: Text(s,
                              style: const TextStyle(fontSize: 12)),
                          backgroundColor:
                              AppPalette.primary.withOpacity(0.08),
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppPalette.primary),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 13, color: AppPalette.textSecondary)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ==================== WORKLOAD CHIP ====================
class _WorkloadChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _WorkloadChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ==================== TEKNISI CARD ====================
class _TeknisiCard extends StatelessWidget {
  final Teknisi teknisi;
  final VoidCallback onDetail;

  const _TeknisiCard({required this.teknisi, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetail,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppPalette.primary.withOpacity(0.1),
              child: Text(
                teknisi.name.substring(0, 1),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teknisi.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(teknisi.specialization,
                      style: const TextStyle(
                          fontSize: 12, color: AppPalette.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined,
                          size: 12, color: AppPalette.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${teknisi.activeTickets} tiket aktif',
                        style: const TextStyle(
                            fontSize: 11, color: AppPalette.textSecondary),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.business_outlined,
                          size: 12, color: AppPalette.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        teknisi.division,
                        style: const TextStyle(
                            fontSize: 11, color: AppPalette.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        teknisi.workloadColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    teknisi.workloadStatus,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: teknisi.workloadColor),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right,
                    color: AppPalette.textSecondary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
