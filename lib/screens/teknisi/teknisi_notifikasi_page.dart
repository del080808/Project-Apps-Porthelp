import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../models/ticket_model.dart';
import '../../services/data_service.dart';
import 'widgets/teknisi_ticket_detail_page.dart';

class _C {
  static const primary = AppPalette.primary;
  static const error = AppPalette.error;
  static const onSurface = AppPalette.textOnSurface;
  static const onSurfaceVariant = AppPalette.textOnSurfaceVariant;
  static const outline = AppPalette.outline;
  static const outlineVariant = AppPalette.outlineVariant;
  static const surfaceContainerLow = AppPalette.surfaceContainerLow;
  static const background = AppPalette.backgroundAlt;
}

// ==================== MODEL ====================
enum _NotifType { statusUpdate, assigned, newComment, resolved, maintenance }

class _Notif {
  final String notificationId;
  final _NotifType type;
  final String title;
  final String body;
  final String time;
  final bool isUnread;
  final bool hasAction;

  // Detail tambahan untuk halaman detail
  final String? ticketId;
  final String? ticketTitle;
  final String? reporter;
  final String? teknisi;
  final String? priority;
  final String? status;
  final String? detailNote;

  const _Notif({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isUnread = false,
    this.hasAction = false,
    this.ticketId,
    this.ticketTitle,
    this.reporter,
    this.teknisi,
    this.priority,
    this.status,
    this.detailNote,
  });
}

// ==================== PAGE ====================
class TeknisiNotifikasiPage extends StatefulWidget {
  const TeknisiNotifikasiPage({super.key});

  @override
  State<TeknisiNotifikasiPage> createState() => _TeknisiNotifikasiPageState();
}

class _TeknisiNotifikasiPageState extends State<TeknisiNotifikasiPage> {
  List<_Notif> _mapNotifications(List<AppNotification> items) {
    return items.map((item) {
      final ticketId = item.ticketId;
      final ticket = ticketId == null
          ? null
          : DataService.getTicketById(ticketId);
      final mappedType = switch (item.type) {
        'assigned' => _NotifType.assigned,
        'comment' => _NotifType.newComment,
        'resolved' => _NotifType.resolved,
        'maintenance' => _NotifType.maintenance,
        _ => _NotifType.statusUpdate,
      };

      return _Notif(
        notificationId: item.id,
        type: mappedType,
        title: item.title,
        body: item.message,
        time: item.time,
        isUnread: !item.isRead,
        hasAction: ticketId != null,
        ticketId: ticketId == null ? null : '#$ticketId',
        ticketTitle: ticket?.title,
        reporter: ticket?.reporter,
        teknisi: ticket?.assignedTo,
        priority: ticket?.priority,
        status: ticket?.status,
        detailNote: ticket?.description,
      );
    }).toList();
  }

  void _markAllRead() {
    DataService.markAllNotificationsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Semua notifikasi ditandai dibaca.'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openTicketOrDetail(BuildContext context, _Notif notif) {
    final rawTicketId = notif.ticketId?.replaceFirst('#', '');
    if (rawTicketId != null) {
      final ticket = DataService.getTicketById(rawTicketId);
      if (ticket != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeknisiTicketDetailPage(ticket: ticket),
          ),
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _NotifDetailPage(notif: notif)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataService.notificationsListenable,
      builder: (context, _) {
        final notifications = _mapNotifications(DataService.getNotifications());
        final unreadCount = notifications.where((n) => n.isUnread).length;
        final unreadItems = notifications.where((n) => n.isUnread).toList();
        final readItems = notifications.where((n) => !n.isUnread).toList();

        return Scaffold(
          backgroundColor: AppPalette.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppPalette.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Notifikasi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Container(
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
                            Expanded(
                              child: Text(
                                unreadCount > 0
                                    ? 'Anda memiliki $unreadCount notifikasi belum dibaca hari ini'
                                    : 'Semua notifikasi sudah dibaca',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppPalette.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
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
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: _SectionHeader(
                        label: 'Terbaru',
                        badgeCount: unreadCount,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  ...unreadItems.map(
                    (n) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: _NotifCard(
                        notif: n,
                        onTap: () {
                          DataService.markNotificationRead(n.notificationId);
                          _openTicketOrDetail(context, n);
                        },
                      ),
                    ),
                  ),
                  if (unreadItems.isNotEmpty && readItems.isNotEmpty)
                    const SizedBox(height: 20),
                  ...readItems.map(
                    (n) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: _NotifCard(
                        notif: n,
                        onTap: () {
                          DataService.markNotificationRead(n.notificationId);
                          _openTicketOrDetail(context, n);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================================
//  HALAMAN DETAIL NOTIFIKASI
// =====================================================================
class _NotifDetailPage extends StatelessWidget {
  final _Notif notif;

  const _NotifDetailPage({required this.notif});

  _IconConfig get _iconConfig {
    switch (notif.type) {
      case _NotifType.assigned:
        return _IconConfig(
          icon: Icons.engineering,
          bg: const Color(0xFFDDE1FF),
          color: _C.primary,
        );
      case _NotifType.statusUpdate:
        return _IconConfig(
          icon: Icons.swap_horiz,
          bg: const Color(0xFFDDE1FF),
          color: _C.primary,
        );
      case _NotifType.newComment:
        return _IconConfig(
          icon: Icons.chat_bubble_outline,
          bg: const Color(0xFFDDE1FF),
          color: _C.primary,
        );
      case _NotifType.resolved:
        return _IconConfig(
          icon: Icons.check_circle_outline,
          bg: Colors.green.shade50,
          color: Colors.green.shade700,
        );
      case _NotifType.maintenance:
        return _IconConfig(
          icon: Icons.warning_amber_rounded,
          bg: const Color(0xFFFFF3E0),
          color: Colors.orange.shade700,
        );
    }
  }

  Color _priorityColor(String? p) {
    switch ((p ?? '').toLowerCase()) {
      case 'urgent':
      case 'kritis':
        return _C.error;
      case 'high':
      case 'tinggi':
        return const Color(0xFF611E00);
      case 'medium':
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return _C.outline;
    }
  }

  Color _statusColor(String? s) {
    if (s == 'Selesai') return Colors.green.shade700;
    if (s == 'Dikerjakan') return Colors.orange.shade700;
    if (s == 'Terbuka') return _C.primary;
    return _C.outline;
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _iconConfig;
    final isMaintenance = notif.type == _NotifType.maintenance;
    final hasTicket = notif.ticketId != null;

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _C.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _C.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: _C.outlineVariant.withOpacity(0.4),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMaintenance ? const Color(0xFFFFF8F0) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isMaintenance
                      ? Colors.orange.shade200
                      : _C.outlineVariant.withOpacity(0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cfg.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cfg.icon, size: 24, color: cfg.color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isMaintenance
                                ? Colors.orange.shade800
                                : _C.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _C.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Isi Notifikasi ──
            _DetailSection(
              title: 'Pesan',
              child: Text(
                notif.body,
                style: const TextStyle(
                  fontSize: 14,
                  color: _C.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),

            // ── Catatan Detail (jika ada) ──
            if (notif.detailNote != null) ...[
              const SizedBox(height: 12),
              _DetailSection(
                title: notif.type == _NotifType.newComment
                    ? 'Komentar Pelapor'
                    : notif.type == _NotifType.maintenance
                    ? 'Informasi Tambahan'
                    : 'Catatan',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMaintenance
                        ? Colors.orange.shade50
                        : _C.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isMaintenance
                          ? Colors.orange.shade200
                          : _C.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    notif.detailNote!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isMaintenance
                          ? Colors.orange.shade800
                          : _C.onSurface,
                      height: 1.5,
                      fontStyle: notif.type == _NotifType.newComment
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ],

            // ── Info Tiket (jika notif punya ticketId) ──
            if (hasTicket) ...[
              const SizedBox(height: 12),
              _DetailSection(
                title: 'Info Tiket',
                child: Column(
                  children: [
                    _InfoRow(label: 'ID Tiket', value: notif.ticketId!),
                    const Divider(height: 20, color: _C.outlineVariant),
                    _InfoRow(label: 'Judul', value: notif.ticketTitle ?? '-'),
                    const Divider(height: 20, color: _C.outlineVariant),
                    _InfoRow(label: 'Pelapor', value: notif.reporter ?? '-'),
                    const Divider(height: 20, color: _C.outlineVariant),
                    _InfoRow(label: 'Teknisi', value: notif.teknisi ?? '-'),
                    const Divider(height: 20, color: _C.outlineVariant),
                    // Prioritas dengan warna
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Prioritas',
                          style: TextStyle(
                            fontSize: 13,
                            color: _C.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: _priorityColor(notif.priority),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              notif.priority ?? '-',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _priorityColor(notif.priority),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: _C.outlineVariant),
                    // Status dengan badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 13,
                            color: _C.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(notif.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            notif.status ?? '-',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(notif.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Action Buttons ──
            if (notif.type == _NotifType.assigned) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tiket ${notif.ticketId} berhasil diambil!',
                        ),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.engineering, size: 18),
                  label: const Text(
                    'Ambil Tiket Ini',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],

            if (notif.type == _NotifType.newComment) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Membuka tiket ${notif.ticketId}...'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text(
                    'Balas Komentar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.onSurface,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],

            if (notif.type == _NotifType.resolved ||
                notif.type == _NotifType.statusUpdate) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Membuka tiket ${notif.ticketId}...'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text(
                    'Lihat Detail Tiket',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.primary,
                    side: const BorderSide(color: _C.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =====================================================================
//  REUSABLE WIDGETS
// =====================================================================

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.outlineVariant.withOpacity(0.35)),
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
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _C.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: _C.onSurfaceVariant),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _C.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== SECTION HEADER ====================
class _SectionHeader extends StatelessWidget {
  final String label;
  final int? badgeCount;

  const _SectionHeader({required this.label, this.badgeCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _C.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
        if (badgeCount != null && badgeCount! > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$badgeCount',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ==================== NOTIF CARD ====================
class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  _IconConfig get _iconConfig {
    switch (notif.type) {
      case _NotifType.assigned:
        return _IconConfig(
          icon: Icons.engineering,
          bg: const Color(0xFFDDE1FF),
          color: _C.primary,
        );
      case _NotifType.statusUpdate:
        return _IconConfig(
          icon: Icons.swap_horiz,
          bg: const Color(0xFFDDE1FF),
          color: _C.primary,
        );
      case _NotifType.newComment:
        return _IconConfig(
          icon: Icons.chat_bubble_outline,
          bg: const Color(0xFFDDE1FF),
          color: _C.primary,
        );
      case _NotifType.resolved:
        return _IconConfig(
          icon: Icons.check_circle_outline,
          bg: Colors.green.shade50,
          color: Colors.green.shade700,
        );
      case _NotifType.maintenance:
        return _IconConfig(
          icon: Icons.warning_amber_rounded,
          bg: const Color(0xFFFFF3E0),
          color: Colors.orange.shade700,
        );
    }
  }

  bool get _isMaintenance => notif.type == _NotifType.maintenance;

  @override
  Widget build(BuildContext context) {
    final cfg = _iconConfig;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _isMaintenance
              ? const Color(0xFFFFF8F0)
              : notif.isUnread
              ? const Color(0xFFF0F4FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isMaintenance
                ? Colors.orange.shade200
                : _C.outlineVariant.withOpacity(0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cfg.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(cfg.icon, size: 20, color: cfg.color),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notif.isUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: _isMaintenance
                            ? Colors.orange.shade800
                            : _C.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _C.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    if (notif.hasAction) ...[
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.onSurface,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Lihat & Balas'),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Time + unread dot
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    notif.time,
                    style: const TextStyle(fontSize: 11, color: _C.outline),
                  ),
                  if (notif.isUnread) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _C.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconConfig {
  final IconData icon;
  final Color bg;
  final Color color;
  const _IconConfig({
    required this.icon,
    required this.bg,
    required this.color,
  });
}
