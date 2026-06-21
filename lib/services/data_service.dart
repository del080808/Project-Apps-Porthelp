import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../models/teknisi_model.dart';
import '../models/notification_model.dart';
import 'package:flutter/foundation.dart'; // ← tambah ini

class DataService {
  static int _ticketSequence = 7;

  static final List<Ticket> _createdTickets = [];
  static final ValueNotifier<int> ticketNotifier = ValueNotifier<int>(0);
  // In-memory ticket store to persist status/fields across page updates
  static final Map<String, Ticket> _ticketStore = {};

  static final Map<String, List<String>> _ticketComments = {
    'TKT-001': [
      'Pelapor: Tolong segera dibantu, ini mengganggu pekerjaan kami.',
      'Teknisi: Sedang saya analisis penyebabnya.',
    ],
    'TKT-004': ['Teknisi: Sedang saya cek di database.'],
    'TKT-005': [
      'Teknisi: Masalah sudah ditemukan, akan diupdate di versi berikutnya.',
      'Pelapor: Terima kasih informasinya.',
      'Teknisi: Tiket ditutup.',
    ],
  };

  static final List<AppNotification> _seedNotifications = [
    AppNotification(
      id: 'N001',
      type: 'status_update',
      title: 'Ticket Status Updated',
      message:
          'Your request #TKT-001 "Printer Kantor Tidak Bisa Digunakan" has been moved to In Progress.',
      time: '2m ago',
      isRead: false,
      ticketId: 'TKT-001',
    ),
    AppNotification(
      id: 'N002',
      type: 'comment',
      title: 'New Comment',
      message:
          'Teknisi Andi added a note to your ticket: "Sedang dicek komponen printer, mohon tunggu."',
      time: '45m ago',
      isRead: false,
      ticketId: 'TKT-001',
      actionLabel: 'Reply',
    ),
    AppNotification(
      id: 'N003',
      type: 'assigned',
      title: 'Technician Assigned',
      message:
          'Teknisi Budi has been assigned to your hardware request #TKT-002.',
      time: '2h ago',
      isRead: false,
      ticketId: 'TKT-002',
    ),
    AppNotification(
      id: 'N004',
      type: 'resolved',
      title: 'Ticket Resolved',
      message:
          'The reported issue "Komputer Tidak Bisa Menyala" has been marked as resolved. Please provide feedback.',
      time: 'Yesterday',
      isRead: true,
      ticketId: 'TKT-004',
    ),
    AppNotification(
      id: 'N005',
      type: 'maintenance',
      title: 'Scheduled Maintenance',
      message:
          'Server aplikasi akan offline untuk maintenance hari Minggu pukul 02.00-04.00 WIB.',
      time: 'Yesterday',
      isRead: true,
    ),
  ];

  static final ValueNotifier<List<AppNotification>> _notificationsNotifier =
      ValueNotifier<List<AppNotification>>(
        List<AppNotification>.from(_seedNotifications),
      );

  static ValueListenable<List<AppNotification>> get notificationsListenable =>
      _notificationsNotifier;

  static List<AppNotification> _currentNotifications() {
    return List<AppNotification>.from(_notificationsNotifier.value);
  }

  static void _setNotifications(List<AppNotification> notifications) {
    _notificationsNotifier.value = List<AppNotification>.from(notifications);
  }

  static void addNotification(AppNotification notification) {
    _setNotifications([notification, ..._currentNotifications()]);
  }

  static void markNotificationRead(String id) {
    final updated = _currentNotifications()
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    _setNotifications(updated);
  }

  static void markAllNotificationsRead() {
    final updated = _currentNotifications()
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _setNotifications(updated);
  }

  static void deleteNotification(String id) {
    final updated = _currentNotifications()..removeWhere((n) => n.id == id);
    _setNotifications(updated);
  }

  static String nextTicketId() {
    final id = 'TKT-${_ticketSequence.toString().padLeft(3, '0')}';
    _ticketSequence += 1;
    return id;
  }

  static void addTicket(Ticket ticket) {
    _ticketComments[ticket.id] = List<String>.from(ticket.comments);
    _createdTickets.insert(0, ticket);
    _ticketStore[ticket.id] = ticket;
  }

  static void ensureTicketLoaded(Ticket ticket) {
    _ticketStore.putIfAbsent(ticket.id, () => ticketWithComments(ticket));
  }

  static Ticket? getTicketById(String id) {
    final t = _ticketStore[id];
    if (t == null) return null;
    return ticketWithComments(t);
  }

  static Ticket _resolveTicket(Ticket ticket) {
    return _ticketStore[ticket.id] ?? ticket;
  }

  static void updateTicketStatus(String ticketId, String status) {
    final existing = _ticketStore[ticketId];
    if (existing == null) return;
    final comments = getTicketComments(ticketId);
    _ticketStore[ticketId] = existing.copyWith(
      status: status,
      comments: comments,
      commentCount: comments.length,
    );
    ticketNotifier.value = ticketNotifier.value + 1;
  }

  static List<String> getTicketComments(String ticketId) {
    return List<String>.unmodifiable(_ticketComments[ticketId] ?? const []);
  }

  static Ticket ticketWithComments(Ticket ticket) {
    final resolved = _resolveTicket(ticket);
    final comments = getTicketComments(resolved.id);
    return resolved.copyWith(comments: comments, commentCount: comments.length);
  }

  static List<Ticket> _withSharedComments(List<Ticket> tickets) {
    return tickets.map(ticketWithComments).toList();
  }

  static void markTicketCompleted(
    String ticketId, {
    List<String> proofPhotoPaths = const [],
  }) {
    final existing = _ticketStore[ticketId];
    if (existing == null) return;

    _ticketProofPhotos[ticketId] = List<String>.from(proofPhotoPaths);
    final comments = getTicketComments(ticketId);
    _ticketStore[ticketId] = existing.copyWith(
      status: 'Selesai',
      completedAt: DateTime.now().toIso8601String(),
      comments: comments,
      commentCount: comments.length,
    );
    addNotification(
      AppNotification(
        id: 'N-${DateTime.now().millisecondsSinceEpoch}',
        type: 'resolved',
        title: 'Ticket Resolved',
        message: 'Tiket #$ticketId telah ditandai selesai oleh teknisi.',
        time: 'Baru saja',
        isRead: false,
        ticketId: ticketId,
      ),
    );
    ticketNotifier.value = ticketNotifier.value + 1;
  }

  static final Map<String, List<String>> _ticketProofPhotos = {};

  static List<String> getTicketProofPhotos(String ticketId) {
    return List<String>.unmodifiable(_ticketProofPhotos[ticketId] ?? const []);
  }

  static bool hasTicketProof(String ticketId) {
    return (_ticketProofPhotos[ticketId] ?? const []).isNotEmpty;
  }

  // Bukti yang diunggah oleh Pelapor (konfirmasi penerimaan)
  static final Map<String, List<String>> _pelaporProofPhotos = {};

  static void addPelaporProofPhotos(String ticketId, List<String> paths) {
    final existing = List<String>.from(
      _pelaporProofPhotos[ticketId] ?? const [],
    );
    existing.addAll(paths);
    _pelaporProofPhotos[ticketId] = existing;
    ticketNotifier.value = ticketNotifier.value + 1;
  }

  static List<String> getPelaporProofPhotos(String ticketId) {
    return List<String>.unmodifiable(_pelaporProofPhotos[ticketId] ?? const []);
  }

  static bool hasPelaporProof(String ticketId) {
    return (_pelaporProofPhotos[ticketId] ?? const []).isNotEmpty;
  }

  // Pelapor dapat mengonfirmasi penyelesaian (jika diperlukan)
  static void confirmTicketCompletionByPelapor(String ticketId) {
    final existing = _ticketStore[ticketId];
    if (existing == null) return;
    final comments = getTicketComments(ticketId);
    _ticketStore[ticketId] = existing.copyWith(
      status: 'Selesai',
      completedAt: DateTime.now().toIso8601String(),
      comments: comments,
      commentCount: comments.length,
    );
    ticketNotifier.value = ticketNotifier.value + 1;
  }

  static void submitTicketRating(
    String ticketId,
    double rating,
    String ratingComment,
  ) {
    final existing = _ticketStore[ticketId];
    if (existing == null) return;

    final comments = getTicketComments(ticketId);
    _ticketStore[ticketId] = existing.copyWith(
      rating: rating,
      ratingComment: ratingComment,
      comments: comments,
      commentCount: comments.length,
    );
    ticketNotifier.value = ticketNotifier.value + 1;
  }

  static void addTicketComment(String ticketId, String comment) {
    final updated = List<String>.from(_ticketComments[ticketId] ?? const []);
    updated.add(comment);
    _ticketComments[ticketId] = updated;
    final existing = _ticketStore[ticketId];
    if (existing != null) {
      _ticketStore[ticketId] = existing.copyWith(
        comments: updated,
        commentCount: updated.length,
      );
    }
    ticketNotifier.value = ticketNotifier.value + 1;
  }

  // Sample Teknisi Data
  static List<Teknisi> getSampleTeknisi() {
    return [
      Teknisi(
        id: 'TKN-001',
        name: 'Andi Wijaya',
        email: 'andi.wijaya@company.com',
        phone: '0812-3456-7890',
        specialization: 'Network & Infrastructure',
        activeTickets: 3,
        skills: ['Network', 'Firewall', 'VPN'],
        division: 'Infrastructure',
      ),
      Teknisi(
        id: 'TKN-002',
        name: 'Budi Santoso',
        email: 'budi.santoso@company.com',
        phone: '0813-4567-8901',
        specialization: 'Software Development',
        activeTickets: 2,
        skills: ['Backend', 'Database', 'API'],
        division: 'Development',
      ),
      Teknisi(
        id: 'TKN-003',
        name: 'Citra Dewi',
        email: 'citra.dewi@company.com',
        phone: '0814-5678-9012',
        specialization: 'Database & Security',
        activeTickets: 1,
        skills: ['Database', 'Security', 'Backup'],
        division: 'Database',
      ),
      Teknisi(
        id: 'TKN-004',
        name: 'Dedi Rahman',
        email: 'dedi.rahman@company.com',
        phone: '0815-6789-0123',
        specialization: 'Hardware & Maintenance',
        activeTickets: 4,
        skills: ['Hardware', 'Server', 'Maintenance'],
        division: 'Hardware',
      ),
    ];
  }

  // Sample Tickets untuk Admin
  static List<Ticket> getAdminSampleTickets() {
    final list = _withSharedComments([
      ..._createdTickets,
      Ticket(
        id: 'TKT-001',
        title: 'Email tidak bisa dikirim dari aplikasi',
        description:
            'Saat saya mencoba mengirim email dari aplikasi, selalu muncul error "Failed to send". Sudah saya coba restart aplikasi tetap sama.',
        priority: 'High',
        status: 'Diproses',
        date: '6 Apr 2025',
        commentCount: 2,
        assignedTo: 'Andi Wijaya',
        reporter: 'Budi Santoso',
        comments: [
          'Pelapor: Tolong segera dibantu, ini mengganggu pekerjaan kami.',
          'Teknisi: Sedang saya analisis penyebabnya.',
        ],
        deadline: DateTime.now().add(const Duration(days: 5)),
        isOverdue: false,
      ),
      Ticket(
        id: 'TKT-002',
        title: 'Permintaan upgrade paket premium',
        description:
            'Saya ingin upgrade ke paket premium dengan 10 user. Mohon dibantu prosesnya.',
        priority: 'Medium',
        status: 'Terbuka',
        date: '6 Apr 2025',
        commentCount: 0,
        assignedTo: null,
        reporter: 'Siti Rahayu',
        comments: [],
        deadline: DateTime.now().add(const Duration(days: 2)),
        isOverdue: false,
      ),
      Ticket(
        id: 'TKT-003',
        title: 'Pertanyaan tentang API documentation',
        description:
            'Saya mencari dokumentasi untuk API endpoint yang belum tersedia.',
        priority: 'Low',
        status: 'Terbuka',
        date: '6 Apr 2025',
        commentCount: 0,
        assignedTo: null,
        reporter: 'Rudi Hartono',
        comments: [],
        deadline: DateTime.now().subtract(const Duration(days: 1)),
        isOverdue: true,
      ),
      Ticket(
        id: 'TKT-004',
        title: 'Perubahan data login tidak tersimpan',
        description:
            'Setelah saya mengubah password, tidak bisa login dengan password baru. Password lama masih bisa dipakai.',
        priority: 'High',
        status: 'Diproses',
        date: '6 Apr 2025',
        commentCount: 1,
        assignedTo: 'Budi Santoso',
        reporter: 'Budi Santoso',
        comments: ['Teknisi: Sedang saya cek di database.'],
        deadline: DateTime.now().add(const Duration(days: 3)),
        isOverdue: false,
      ),
      Ticket(
        id: 'TKT-005',
        title: 'Export data ke Excel tidak berfungsi',
        description:
            'Fitur export data berhenti bekerja setelah update terakhir. Tombol export tidak merespon.',
        priority: 'Medium',
        status: 'Selesai',
        date: '5 Apr 2025',
        commentCount: 3,
        assignedTo: 'Citra Dewi',
        reporter: 'Citra Dewi',
        comments: [
          'Teknisi: Masalah sudah ditemukan, akan diupdate di versi berikutnya.',
          'Pelapor: Terima kasih informasinya.',
          'Teknisi: Tiket ditutup.',
        ],
        rating: 4.5,
        deadline: DateTime.now().subtract(const Duration(days: 2)),
        isOverdue: true,
      ),
      Ticket(
        id: 'TKT-006',
        title: 'Aplikasi sering force close',
        description:
            'Aplikasi tiba-tiba force close saat membuka halaman laporan.',
        priority: 'Urgent',
        status: 'Terbuka',
        date: '7 Apr 2025',
        commentCount: 0,
        assignedTo: null,
        reporter: 'Rudi Hartono',
        comments: [],
        deadline: DateTime.now().add(const Duration(hours: 12)),
        isOverdue: false,
      ),
    ]);
    for (final t in list) {
      _ticketStore.putIfAbsent(t.id, () => t);
    }
    return list;
  }

  // Sample Tickets untuk Pelapor (user: Budi Santoso)
  static List<Ticket> getPelaporSampleTickets() {
    final list = _withSharedComments([
      ..._createdTickets,
      Ticket(
        id: 'TKT-001',
        title: 'Email tidak bisa dikirim dari aplikasi',
        description:
            'Saat saya mencoba mengirim email dari aplikasi, selalu muncul error.',
        priority: 'High',
        status: 'Dikerjakan',
        date: '6 Apr 2025',
        commentCount: 2,
        assignedTo: 'Andi Wijaya',
        reporter: 'Budi Santoso',
        comments: [
          'Pelapor: Tolong segera dibantu, ini mengganggu pekerjaan kami.',
          'Teknisi: Sedang saya analisis penyebabnya.',
        ],
        deadline: DateTime.now().add(const Duration(days: 5)),
        isOverdue: false,
      ),
      Ticket(
        id: 'TKT-002',
        title: 'Permintaan upgrade paket premium',
        description: 'Saya ingin upgrade ke paket premium dengan 10 user...',
        priority: 'Medium',
        status: 'Terbuka',
        date: '6 Apr 2025',
        commentCount: 0,
        assignedTo: null,
        reporter: 'Budi Santoso',
        comments: [],
        deadline: DateTime.now().add(const Duration(days: 2)),
        isOverdue: false,
      ),
      Ticket(
        id: 'TKT-003',
        title: 'Pertanyaan tentang API documentation',
        description:
            'Saya mencari dokumentasi untuk API endpoint yang belum tersedia.',
        priority: 'Low',
        status: 'Terbuka',
        date: '6 Apr 2025',
        commentCount: 0,
        assignedTo: null,
        reporter: 'Budi Santoso',
        comments: [],
        deadline: DateTime.now().subtract(const Duration(days: 1)),
        isOverdue: true,
      ),
      Ticket(
        id: 'TKT-004',
        title: 'Perubahan data login tidak tersimpan',
        description:
            'Setelah saya mengubah password, tidak bisa login dengan password baru.',
        priority: 'High',
        status: 'Dikerjakan',
        date: '6 Apr 2025',
        commentCount: 1,
        assignedTo: 'Budi Santoso',
        reporter: 'Budi Santoso',
        comments: ['Teknisi: Sedang saya cek di database.'],
        deadline: DateTime.now().add(const Duration(days: 3)),
        isOverdue: false,
      ),
      Ticket(
        id: 'TKT-005',
        title: 'Export data ke Excel tidak berfungsi',
        description:
            'Fitur export data berhenti bekerja setelah update terakhir.',
        priority: 'Medium',
        status: 'Selesai',
        date: '5 Apr 2025',
        commentCount: 3,
        assignedTo: 'Citra Dewi',
        reporter: 'Budi Santoso',
        comments: [
          'Teknisi: Masalah sudah ditemukan, akan diupdate di versi berikutnya.',
          'Pelapor: Terima kasih informasinya.',
          'Teknisi: Tiket ditutup.',
        ],
        rating: 4,
        ratingComment: 'Teknisi cepat merespon dan masalah teratasi.',
        deadline: DateTime.now().subtract(const Duration(days: 2)),
        isOverdue: true,
      ),
    ]);
    for (final t in list) {
      _ticketStore.putIfAbsent(t.id, () => t);
    }
    return list;
  }

  // Sample Tickets untuk Teknisi (Andi Wijaya)
  static List<Ticket> getTeknisiSampleTickets() {
    final list = _withSharedComments([
      ..._createdTickets,
      Ticket(
        id: 'TKT-001',
        title: 'Email tidak bisa dikirim dari aplikasi',
        description:
            'Saat saya mencoba mengirim email dari aplikasi, selalu muncul error "Failed to send". Sudah saya coba restart aplikasi tetap sama.',
        priority: 'High',
        status: 'Dikerjakan',
        date: '6 Apr 2025',
        commentCount: 2,
        assignedTo: 'Andi Wijaya',
        reporter: 'Budi Santoso',
        comments: [
          'Pelapor: Tolong segera dibantu, ini mengganggu pekerjaan kami.',
          'Teknisi: Sedang saya analisis penyebabnya.',
        ],
        deadline: DateTime.now().add(const Duration(days: 5)),
        isOverdue: false,
      ),
      Ticket(
        id: 'TKT-002',
        title: 'Permintaan upgrade paket premium',
        description:
            'Saya ingin upgrade ke paket premium dengan 10 user. Mohon dibantu prosesnya.',
        priority: 'Medium',
        status: 'Terbuka',
        date: '6 Apr 2025',
        commentCount: 0,
        assignedTo: null,
        reporter: 'Siti Rahayu',
        comments: [],
        deadline: DateTime.now().add(const Duration(days: 2)),
        isOverdue: false,
      ),
      Ticket(
        id: 'TKT-004',
        title: 'Perubahan data login tidak tersimpan',
        description:
            'Setelah saya mengubah password, tidak bisa login dengan password baru. Password lama masih bisa dipakai.',
        priority: 'High',
        status: 'Dikerjakan',
        date: '6 Apr 2025',
        commentCount: 1,
        assignedTo: 'Andi Wijaya',
        reporter: 'Budi Santoso',
        comments: ['Teknisi: Sedang saya cek di database.'],
        deadline: DateTime.now().add(const Duration(days: 3)),
        isOverdue: false,
      ),
      Ticket(
        id: 'TKT-005',
        title: 'Export data ke Excel tidak berfungsi',
        description:
            'Fitur export data berhenti bekerja setelah update terakhir. Tombol export tidak merespon.',
        priority: 'Medium',
        status: 'Selesai',
        date: '5 Apr 2025',
        commentCount: 3,
        assignedTo: 'Andi Wijaya',
        reporter: 'Citra Dewi',
        comments: [
          'Teknisi: Masalah sudah ditemukan, akan diupdate di versi berikutnya.',
          'Pelapor: Terima kasih informasinya.',
          'Teknisi: Tiket ditutup.',
        ],
        rating: 4.5,
        deadline: DateTime.now().subtract(const Duration(days: 2)),
        isOverdue: true,
      ),
      Ticket(
        id: 'TKT-007',
        title: 'Aplikasi sering force close',
        description:
            'Aplikasi tiba-tiba force close saat membuka halaman laporan.',
        priority: 'Urgent',
        status: 'Terbuka',
        date: '7 Apr 2025',
        commentCount: 0,
        assignedTo: null,
        reporter: 'Rudi Hartono',
        comments: [],
        deadline: DateTime.now().add(const Duration(hours: 12)),
        isOverdue: false,
      ),
    ]);
    for (final t in list) {
      _ticketStore.putIfAbsent(t.id, () => t);
    }
    return list;
  }

  // ─── METHOD BARU: Notifications ───────────────────────────────────────────

  static List<AppNotification> getNotifications() {
    return _currentNotifications();
  }

  // Ambil aktivitas terbaru dari notifikasi (untuk dashboard)
  static List<Map<String, dynamic>> getRecentActivities() {
    final notifs = getNotifications();
    return notifs.take(3).map((n) {
      IconData icon;
      switch (n.type) {
        case 'comment':
          icon = Icons.comment;
          break;
        case 'status_update':
          icon = Icons.update;
          break;
        case 'assigned':
          icon = Icons.engineering;
          break;
        case 'resolved':
          icon = Icons.check_circle;
          break;
        default:
          icon = Icons.notifications;
      }
      return {
        'icon': icon,
        'text': n.message,
        'time': n.time,
        'isRead': n.isRead,
      };
    }).toList();
  }
}
