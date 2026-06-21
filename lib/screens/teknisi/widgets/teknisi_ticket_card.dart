import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ticket_model.dart';
import 'teknisi_ticket_detail_page.dart';

class _AppColors {
  static const primary = AppPalette.primary;
  static const secondary = AppPalette.secondary;
  static const tertiary = AppPalette.tertiary;
  static const error = AppPalette.error;
  static const onSurface = AppPalette.textOnSurface;
  static const onSurfaceVariant = AppPalette.textOnSurfaceVariant;
  static const outline = AppPalette.outline;
  static const outlineVariant = AppPalette.outlineVariant;
  static const surfaceContainerLow = AppPalette.surfaceContainerLow;
  static const surfaceContainerHigh = AppPalette.surfaceContainerHigh;
}

class TeknisiTicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TeknisiTicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  // Priority styling
  Color get _priorityBorderColor {
    switch (ticket.priority.toLowerCase()) {
      case 'urgent':
      case 'kritis':
        return _AppColors.error;
      case 'high':
      case 'tinggi':
        return _AppColors.tertiary;
      case 'medium':
      case 'sedang':
        return _AppColors.secondary;
      default:
        return _AppColors.outline;
    }
  }

  Color get _priorityBadgeBg {
    switch (ticket.priority.toLowerCase()) {
      case 'urgent':
      case 'kritis':
        return _AppColors.error.withOpacity(0.08);
      case 'high':
      case 'tinggi':
        return _AppColors.tertiary.withOpacity(0.08);
      case 'medium':
      case 'sedang':
        return _AppColors.secondary.withOpacity(0.08);
      default:
        return _AppColors.outline.withOpacity(0.08);
    }
  }

  Color get _priorityTextColor {
    switch (ticket.priority.toLowerCase()) {
      case 'urgent':
      case 'kritis':
        return _AppColors.error;
      case 'high':
      case 'tinggi':
        return _AppColors.tertiary;
      case 'medium':
      case 'sedang':
        return _AppColors.secondary;
      default:
        return _AppColors.outline;
    }
  }

  // Status styling
  Color get _statusColor {
    if (ticket.status.contains('Selesai')) return Colors.green.shade700;
    if (ticket.status.contains('Dikerjakan')) return Colors.orange.shade700;
    if (ticket.status.contains('Terbuka')) return _AppColors.secondary;
    return _AppColors.outline;
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeknisiTicketDetailPage(ticket: ticket),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: _priorityBorderColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              // ── Header: priority badge + ticket ID + more icon ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Priority badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _priorityBadgeBg,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 3,
                                    backgroundColor: _priorityTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ticket.priority.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _priorityTextColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Ticket ID
                            Text(
                              '#${ticket.id}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _AppColors.outline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Title
                        Text(
                          ticket.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _AppColors.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.more_vert,
                    color: _AppColors.outline,
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Reporter row ──
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: _AppColors.surfaceContainerHigh,
                    child: Text(
                      ticket.reporter.isNotEmpty
                          ? ticket.reporter[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Dilaporkan oleh ',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _AppColors.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: ticket.reporter,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _AppColors.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: ' • ${_getTimeAgo(ticket.date)}',
                            style: const TextStyle(color: _AppColors.outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Info grid (Status + Teknisi) ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoCell(
                        label: 'Status',
                        value: ticket.status,
                        valueColor: _statusColor,
                      ),
                    ),
                    Expanded(
                      child: _InfoCell(
                        label: 'Teknisi',
                        value: ticket.assignedTo ?? 'Belum assign',
                      ),
                    ),
                  ],
                ),
              ),

              // ── SLA info ──
              if (ticket.slaStatus.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: _AppColors.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SLA: ${ticket.slaStatus}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // ── Action buttons ──
              if (ticket.status != 'Selesai') ...[
                Row(
                  children: [
                    // Tombol utama: buka detail untuk lanjut selesaikan
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openDetail(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ticket.status == 'Terbuka'
                              ? _AppColors.primary
                              : Colors.green.shade700,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: Text(
                          ticket.status == 'Terbuka'
                              ? 'Ambil Tiket'
                              : 'Selesaikan',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol detail
                    OutlinedButton(
                      onPressed: () => _openDetail(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: _AppColors.outlineVariant,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                      ),
                      child: Icon(
                        ticket.status == 'Dikerjakan'
                            ? Icons.visibility_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: _AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Tiket selesai — hanya tombol lihat detail
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: _AppColors.onSurfaceVariant,
                    ),
                    label: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: _AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(String date) {
    if (date.contains('6 Apr')) return '2 jam lalu';
    if (date.contains('5 Apr')) return '1 hari lalu';
    if (date.contains('7 Apr')) return 'baru saja';
    return date;
  }
}

// ==================== INFO CELL WIDGET ====================
class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCell({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: _AppColors.outline),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? _AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
