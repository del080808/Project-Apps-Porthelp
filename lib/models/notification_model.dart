class AppNotification {
  final String id;
  final String type; // 'status_update' | 'comment' | 'assigned' | 'resolved' | 'maintenance'
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String? ticketId;
  final String? actionLabel;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    this.ticketId,
    this.actionLabel,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        time: time,
        isRead: isRead ?? this.isRead,
        ticketId: ticketId,
        actionLabel: actionLabel,
      );
}