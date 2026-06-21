import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ticket_model.dart';

class PelaporTicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const PelaporTicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  Color _getPriorityColor() {
    switch (ticket.priority.toLowerCase()) {
      case 'Critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  Color _getStatusColor() {
    if (ticket.status.contains('Selesai')) return Colors.green;
    if (ticket.status.contains('Dikerjakan')) return Colors.orange;
    if (ticket.status.contains('Terbuka')) return Colors.blue;
    return Colors.grey;
  }

  String _getStatusLabel() {
    if (ticket.status.contains('Selesai')) return 'Resolved';
    if (ticket.status.contains('Dikerjakan')) return 'In Progress';
    if (ticket.status.contains('Terbuka')) return 'Open';
    return ticket.status;
  }

  /// Kembalikan kategori dari field category jika ada,
  /// fallback ke tebakan dari judul (legacy).
  String _getCategoryLabel() {
    // Jika Ticket model sudah punya field category, pakai itu:
    // if (ticket.category != null) return ticket.category!;

    // Fallback sementara (hapus setelah field category ditambahkan ke model):
    final title = ticket.title.toLowerCase();
    if (title.contains('printer') ||
        title.contains('komputer') ||
        title.contains('laptop') ||
        title.contains('monitor') ||
        title.contains('keyboard') ||
        title.contains('mouse')) {
      return 'Hardware';
    }
    if (title.contains('internet') || title.contains('koneksi') || title.contains('wifi')) {
      return 'Network';
    }
    if (title.contains('ac') || title.contains('listrik') || title.contains('lampu')) {
      return 'Fasilitas';
    }
    return 'Software';
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Baris 1: ID + Priority badge ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${ticket.id}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          ticket.priority,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Baris 2: Judul ──
              Text(
                ticket.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // ── Baris 3: Category chip + Status chip ──
              Row(
                children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.mutedSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppPalette.border),
                    ),
                    child: Text(
                      _getCategoryLabel(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusLabel(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  // Rating (jika ada)
                  if (ticket.rating != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 11, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            '${ticket.rating}/5',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // ── Divider ──
              Divider(color: AppPalette.mutedSurface, height: 1),
              const SizedBox(height: 10),

              // ── Baris 4: Assignee + Tanggal ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Avatar assignee
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppPalette.secondary.withOpacity(0.14),
                        child: Text(
                          ticket.assignedTo != null
                              ? ticket.assignedTo![0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ticket.assignedTo ?? 'Unassigned',
                        style: TextStyle(
                          fontSize: 12,
                          color: ticket.assignedTo != null
                              ? AppPalette.textSecondary
                              : AppPalette.textSecondary.withOpacity(0.65),
                          fontStyle: ticket.assignedTo == null
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                  // Tanggal + komentar
                  Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 12,
                        color: AppPalette.textSecondary.withOpacity(0.6),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${ticket.commentCount}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppPalette.textSecondary.withOpacity(0.65),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        ticket.date,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppPalette.textSecondary.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}