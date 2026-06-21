import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/data_service.dart';
import 'pelapor_detail_tiket_page.dart';
import '../../core/theme/app_theme.dart';

class PelaporNotifikasiPage extends StatefulWidget {
  const PelaporNotifikasiPage({super.key});

  @override
  State<PelaporNotifikasiPage> createState() => _PelaporNotifikasiPageState();
}

class _PelaporNotifikasiPageState extends State<PelaporNotifikasiPage> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = DataService.getNotifications();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      DataService.markAllNotificationsRead();
      _notifications = DataService.getNotifications();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah dibaca'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markOneRead(String id) {
    setState(() {
      DataService.markNotificationRead(id);
      _notifications = DataService.getNotifications();
    });
  }

  void _deleteNotif(String id) {
    setState(() {
      DataService.deleteNotification(id);
      _notifications = DataService.getNotifications();
    });
  }

  void _openTicket(BuildContext context, String? ticketId) {
    if (ticketId == null) return;
    final tickets = DataService.getPelaporSampleTickets();
    final ticket = tickets.firstWhere(
      (t) => t.id == ticketId,
      orElse: () => tickets.first,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PelaporDetailTiketPage(ticket: ticket)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).toList();
    final read = _notifications.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar sederhana hanya judul ──
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppPalette.primary,
            elevation: 0,
            title: const Text(
              'Notifikasi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),

          // ── Body ──
          _notifications.isEmpty
              ? SliverFillRemaining(child: _buildEmpty())
              : SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Info bar unread + tombol tandai semua ──
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _unreadCount > 0
                                ? 'Anda memiliki $_unreadCount notifikasi belum dibaca hari ini'
                                : 'Semua notifikasi sudah dibaca',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppPalette.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_unreadCount > 0)
                            GestureDetector(
                              onTap: _markAllRead,
                              child: Text(
                                'Tandai semua dibaca',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppPalette.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ── Unread Section ──
                    if (unread.isNotEmpty) ...[
                      _sectionHeader('Terbaru', unread.length),
                      ...unread.map(
                        (n) => _NotifCard(
                          notif: n,
                          onTap: () => _markOneRead(n.id),
                          onViewTicket: () => _openTicket(context, n.ticketId),
                          onReply: () {
                            _markOneRead(n.id);
                            _openTicket(context, n.ticketId);
                          },
                          onDismiss: () => _deleteNotif(n.id),
                        ),
                      ),
                    ],

                    // ── Read Section ──
                    if (read.isNotEmpty) ...[
                      _sectionHeader('Sebelumnya', null),
                      ...read.map(
                        (n) => _NotifCard(
                          notif: n,
                          onTap: () {},
                          onViewTicket: () => _openTicket(context, n.ticketId),
                          onReply: () => _openTicket(context, n.ticketId),
                          onDismiss: () => _deleteNotif(n.id),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ]),
                ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int? count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppPalette.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppPalette.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppPalette.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 52,
              color: AppPalette.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi baru akan muncul di sini',
            style: TextStyle(
              fontSize: 13,
              color: AppPalette.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// NOTIF CARD
// ══════════════════════════════════════════
class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;
  final VoidCallback onViewTicket;
  final VoidCallback onReply;
  final VoidCallback onDismiss;

  const _NotifCard({
    required this.notif,
    required this.onTap,
    required this.onViewTicket,
    required this.onReply,
    required this.onDismiss,
  });

  IconData get _icon {
    switch (notif.type) {
      case 'status_update':
        return Icons.swap_horiz_rounded;
      case 'comment':
        return Icons.chat_bubble_outline;
      case 'assigned':
        return Icons.person_add_outlined;
      case 'resolved':
        return Icons.check_circle_outline;
      case 'maintenance':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _accentColor {
    switch (notif.type) {
      case 'status_update':
        return AppPalette.primary;
      case 'comment':
        return const Color(0xFF475569);
      case 'assigned':
        return AppPalette.secondary;
      case 'resolved':
        return const Color(0xFF16A34A);
      case 'maintenance':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMaintenance = notif.type == 'maintenance';

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isMaintenance
                ? const Color(0xFFFFF7ED)
                : notif.isRead
                ? AppPalette.surface
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMaintenance
                  ? const Color(0xFFFCD9A7)
                  : notif.isRead
                  ? AppPalette.border
                  : const Color(0xFFBFDBFE),
              width: 1,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon bulat
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, color: _accentColor, size: 22),
                ),
                const SizedBox(width: 12),

                // Konten
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isMaintenance
                                    ? const Color(0xFF9A3412)
                                    : AppPalette.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                notif.time,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppPalette.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              if (!notif.isRead)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        notif.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppPalette.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      if (notif.type == 'comment' &&
                          notif.ticketId != null) ...[
                        const SizedBox(height: 12),
                        _buildButton(
                          label: 'Balas Komentar',
                          isPrimary: true,
                          color: _accentColor,
                          onTap: onReply,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required bool isPrimary,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary ? color : color.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
