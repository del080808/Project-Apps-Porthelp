import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../services/data_service.dart';

class AdminNotifikasiPage extends StatefulWidget {
  const AdminNotifikasiPage({super.key});

  @override
  State<AdminNotifikasiPage> createState() => _AdminNotifikasiPageState();
}

class _AdminNotifikasiPageState extends State<AdminNotifikasiPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ValueListenableBuilder<List<AppNotification>>(
              valueListenable: DataService.notificationsListenable,
              builder: (_, notifs, __) {
                if (notifs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none,
                            size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Tidak ada notifikasi',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _NotifCard(
                    notif: notifs[i],
                    onRead: () =>
                        DataService.markNotificationRead(notifs[i].id),
                    onDelete: () =>
                        DataService.deleteNotification(notifs[i].id),
                  ),
                );
              },
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
          const Icon(Icons.notifications, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          const Text(
            'Notifikasi',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: DataService.markAllNotificationsRead,
            child: const Text(
              'Tandai Semua',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onRead;
  final VoidCallback onDelete;

  const _NotifCard({
    required this.notif,
    required this.onRead,
    required this.onDelete,
  });

  IconData get _icon {
    switch (notif.type) {
      case 'comment':
        return Icons.comment_outlined;
      case 'status_update':
        return Icons.update_outlined;
      case 'assigned':
        return Icons.engineering_outlined;
      case 'resolved':
        return Icons.check_circle_outline;
      case 'maintenance':
        return Icons.build_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notif.type) {
      case 'comment':
        return const Color(0xFF2563EB);
      case 'status_update':
        return const Color(0xFFD97706);
      case 'assigned':
        return AppPalette.primary;
      case 'resolved':
        return const Color(0xFF059669);
      case 'maintenance':
        return Colors.purple;
      default:
        return AppPalette.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: notif.isRead ? null : onRead,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead ? Colors.white : const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notif.isRead
                  ? const Color(0xFFE5E7EB)
                  : AppPalette.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, size: 18, color: _iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: notif.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: AppPalette.textPrimary,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppPalette.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: const TextStyle(
                          fontSize: 12, color: AppPalette.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.time,
                      style: const TextStyle(
                          fontSize: 11, color: AppPalette.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
