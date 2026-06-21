import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ticket_model.dart';
import '../../../models/teknisi_model.dart';
import '../../../services/data_service.dart';

class AdminTicketDetailPage extends StatefulWidget {
  final Ticket ticket;
  const AdminTicketDetailPage({super.key, required this.ticket});

  @override
  State<AdminTicketDetailPage> createState() => _AdminTicketDetailPageState();
}

class _AdminTicketDetailPageState extends State<AdminTicketDetailPage> {
  late Ticket _ticket;
  final _commentCtrl = TextEditingController();
  bool _sendingComment = false;

  @override
  void initState() {
    super.initState();
    _ticket = DataService.getTicketById(widget.ticket.id) ?? widget.ticket;
    DataService.ticketNotifier.addListener(_refresh);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    DataService.ticketNotifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _ticket = DataService.getTicketById(_ticket.id) ?? _ticket;
      });
    }
  }

  Color get _priorityColor {
    switch (_ticket.priority) {
      case 'Urgent':
        return const Color(0xFFDC2626);
      case 'High':
        return const Color(0xFFD97706);
      case 'Medium':
        return const Color(0xFF2563EB);
      default:
        return Colors.grey;
    }
  }

  Color get _statusColor {
    switch (_ticket.status) {
      case 'Terbuka':
        return const Color(0xFF2563EB);
      case 'Diproses':
      case 'Dikerjakan':
        return const Color(0xFFD97706);
      case 'Selesai':
        return const Color(0xFF059669);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: Text(_ticket.id,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleAction,
            itemBuilder: (_) => [
              if (_ticket.status == 'Terbuka')
                const PopupMenuItem(
                    value: 'assign', child: Text('Tugaskan Teknisi')),
              if (_ticket.status != 'Selesai')
                const PopupMenuItem(
                    value: 'close', child: Text('Tutup Tiket')),
              const PopupMenuItem(
                  value: 'priority', child: Text('Ubah Prioritas')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(),
                  const SizedBox(height: 14),
                  _buildTicketInfo(),
                  const SizedBox(height: 14),
                  _buildAssignmentCard(),
                  const SizedBox(height: 14),
                  _buildSLACard(),
                  const SizedBox(height: 14),
                  _buildComments(),
                  const SizedBox(height: 14),
                  if (_ticket.rating != null) _buildRatingCard(),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
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
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _ticket.priority,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _priorityColor),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _ticket.status,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _ticket.title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppPalette.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            _ticket.description,
            style: const TextStyle(
                fontSize: 13, color: AppPalette.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfo() {
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
          const Text('Detail Tiket',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimary)),
          const Divider(height: 16),
          _row(Icons.tag, 'ID Tiket', _ticket.id),
          _row(Icons.person_outline, 'Pelapor', _ticket.reporter),
          _row(Icons.calendar_today_outlined, 'Tanggal Masuk', _ticket.date),
          _row(Icons.comment_outlined, 'Komentar',
              '${_ticket.commentCount} komentar'),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppPalette.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.engineering_outlined,
                color: AppPalette.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Teknisi Ditugaskan',
                    style: TextStyle(
                        fontSize: 12, color: AppPalette.textSecondary)),
                Text(
                  _ticket.assignedTo ?? 'Belum ditugaskan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ticket.assignedTo != null
                        ? AppPalette.textPrimary
                        : AppPalette.textSecondary,
                  ),
                ),
                if (_ticket.assignedAt != null)
                  Text('Ditugaskan: ${_ticket.assignedAt}',
                      style: const TextStyle(
                          fontSize: 11, color: AppPalette.textSecondary)),
              ],
            ),
          ),
          if (_ticket.status == 'Terbuka')
            ElevatedButton(
              onPressed: () => _showAssignDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Tugaskan',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildSLACard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _ticket.slaColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _ticket.slaColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: _ticket.slaColor, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status SLA: ${_ticket.slaStatus}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _ticket.slaColor),
              ),
              Text(
                'Deadline: ${_ticket.deadline.day}/${_ticket.deadline.month}/${_ticket.deadline.year}',
                style: TextStyle(
                    fontSize: 12,
                    color: _ticket.slaColor.withOpacity(0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    final comments = _ticket.comments;
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
          Text('Komentar (${comments.length})',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold)),
          if (comments.isEmpty) ...[
            const SizedBox(height: 12),
            const Center(
                child: Text('Belum ada komentar',
                    style: TextStyle(
                        fontSize: 13, color: AppPalette.textSecondary))),
          ] else ...[
            const SizedBox(height: 12),
            ...comments.map((c) => _buildCommentBubble(c)),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentBubble(String comment) {
    final isAdmin = comment.startsWith('Admin:');
    final isTeknisi = comment.startsWith('Teknisi:');
    final text = comment.contains(': ')
        ? comment.substring(comment.indexOf(': ') + 2)
        : comment;
    final sender = comment.contains(': ')
        ? comment.substring(0, comment.indexOf(': '))
        : 'Sistem';

    Color bubbleColor;
    Color textColor;
    if (isAdmin) {
      bubbleColor = const Color(0xFFEDE9FE);
      textColor = const Color(0xFF5B21B6);
    } else if (isTeknisi) {
      bubbleColor = const Color(0xFFEEF2FF);
      textColor = AppPalette.primary;
    } else {
      bubbleColor = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF166534);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sender,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          const SizedBox(height: 4),
          Text(text,
              style: const TextStyle(
                  fontSize: 13, color: AppPalette.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
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
          const Text('Rating Pelapor',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(5, (i) {
                final rating = _ticket.rating ?? 0;
                return Icon(
                  i < rating.floor()
                      ? Icons.star
                      : i < rating
                          ? Icons.star_half
                          : Icons.star_border,
                  color: const Color(0xFFD97706),
                  size: 22,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${_ticket.rating}/5',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706)),
              ),
            ],
          ),
          if (_ticket.ratingComment != null &&
              _ticket.ratingComment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('"${_ticket.ratingComment}"',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppPalette.textSecondary,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentCtrl,
              decoration: InputDecoration(
                hintText: 'Tulis komentar admin...',
                hintStyle: const TextStyle(
                    fontSize: 13, color: AppPalette.textSecondary),
                filled: true,
                fillColor: const Color(0xFFF0F3FA),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 10),
          _sendingComment
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : GestureDetector(
                  onTap: _sendComment,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppPalette.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send,
                        color: Colors.white, size: 18),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppPalette.primary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 12, color: AppPalette.textSecondary)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _sendComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sendingComment = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      DataService.addTicketComment(_ticket.id, 'Admin: $text');
      _commentCtrl.clear();
      if (mounted) setState(() => _sendingComment = false);
    });
  }

  void _handleAction(String action) {
    switch (action) {
      case 'assign':
        _showAssignDialog();
        break;
      case 'close':
        _showCloseDialog();
        break;
      case 'priority':
        _showPriorityDialog();
        break;
    }
  }

  void _showAssignDialog() {
    final teknisiList = DataService.getSampleTeknisi();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Teknisi',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 16),
            ...teknisiList.map((tk) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppPalette.primary.withOpacity(0.1),
                    child: Text(tk.name.substring(0, 1),
                        style: const TextStyle(
                            color: AppPalette.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                  title: Text(tk.name,
                      style: const TextStyle(fontSize: 13)),
                  subtitle: Text(tk.specialization,
                      style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tk.workloadColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(tk.workloadStatus,
                        style: TextStyle(
                            fontSize: 10,
                            color: tk.workloadColor,
                            fontWeight: FontWeight.bold)),
                  ),
                  onTap: () {
                    DataService.updateTicketStatus(_ticket.id, 'Diproses');
                    DataService.addTicketComment(
                        _ticket.id,
                        'Admin: Tiket ditugaskan ke ${tk.name}.');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Tiket ditugaskan ke ${tk.name}'),
                        backgroundColor: const Color(0xFF059669),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showCloseDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tutup Tiket'),
        content: const Text(
            'Apakah Anda yakin ingin menutup tiket ini secara manual?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              DataService.updateTicketStatus(_ticket.id, 'Selesai');
              DataService.addTicketComment(
                  _ticket.id, 'Admin: Tiket ditutup oleh admin.');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669)),
            child: const Text('Tutup Tiket',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPriorityDialog() {
    final priorities = ['Urgent', 'High', 'Medium', 'Low'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ubah Prioritas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: priorities
              .map((p) => RadioListTile<String>(
                    value: p,
                    groupValue: _ticket.priority,
                    title: Text(p),
                    onChanged: (v) {
                      // In real app, would update priority in service
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Prioritas diubah ke $p'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
