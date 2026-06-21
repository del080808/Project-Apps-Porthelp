import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ticket_model.dart';
import '../../../services/data_service.dart';

class _C {
  static const primary = AppPalette.primary;
  static const secondary = AppPalette.secondary;
  static const error = AppPalette.error;
  static const amber = AppPalette.amber;
  static const green = AppPalette.green;
  static const onSurface = AppPalette.textOnSurface;
  static const onSurfaceVariant = AppPalette.textOnSurfaceVariant;
  static const muted = AppPalette.muted;
  static const hint = AppPalette.hint;
  static const background = AppPalette.surfaceContainerLow;
  static const surface = AppPalette.surface;
  static const surfaceVar = AppPalette.surfaceVar;
  static const outline = AppPalette.outlineVariant;
  static const outlineLight = AppPalette.outlineLight;
  static const tagRed = AppPalette.tagRed;
  static const tagBlue = AppPalette.tagBlue;
  static const tagAmber = AppPalette.tagAmber;
  static const commentGreen = AppPalette.commentGreen;
  static const commentBlue = AppPalette.commentBlue;
}

// ==================== DETAIL PAGE ====================
class TeknisiTicketDetailPage extends StatefulWidget {
  final Ticket ticket;
  const TeknisiTicketDetailPage({super.key, required this.ticket});

  @override
  State<TeknisiTicketDetailPage> createState() =>
      _TeknisiTicketDetailPageState();
}

class _TeknisiTicketDetailPageState extends State<TeknisiTicketDetailPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  final List<XFile> _photos = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    DataService.ensureTicketLoaded(widget.ticket);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'urgent':
      case 'kritis':
        return _C.error;
      case 'high':
      case 'tinggi':
        return _C.amber;
      case 'medium':
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return _C.muted;
    }
  }

  // ── PICK PHOTOS ──
  Future<void> _pickPhotos() async {
    if (_photos.length >= 5) {
      _showSnack('Maksimal 5 foto');
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    final remaining = 5 - _photos.length;
    setState(() => _photos.addAll(picked.take(remaining)));
    if (picked.length > remaining) {
      _showSnack('Hanya $remaining foto yang ditambahkan (batas 5)');
    }
  }

  // ── SEND COMMENT ──
  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    DataService.addTicketComment(widget.ticket.id, 'Teknisi: $text');
    setState(() {
      _commentController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ── CONFIRM DONE ──
  Future<void> _confirmSelesai() async {
    if (_photos.isEmpty) {
      _showSnack('Upload minimal 1 foto bukti pengerjaan terlebih dahulu');
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Selesai',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'Tandai tiket "${widget.ticket.title}" sebagai selesai?\n\n${_photos.length} foto bukti akan dikirimkan.',
          style: const TextStyle(color: _C.onSurfaceVariant, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: _C.muted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Selesaikan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _submitting = true);
    // simulate upload/processing
    await Future.delayed(const Duration(milliseconds: 1200));
    // persist status update in DataService so other screens see it
    DataService.markTicketCompleted(
      widget.ticket.id,
      proofPhotoPaths: _photos.map((photo) => photo.path).toList(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    _showSnack('Tiket berhasil diselesaikan ✓');
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: _C.onSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<_Comment> _buildComments(List<String> rawComments) {
    return rawComments.map((raw) {
      final isTeknisi = raw.startsWith('Teknisi:');
      final role = isTeknisi ? 'Teknisi' : 'Pelapor';
      return _Comment(
        role: role,
        text: raw.replaceAll('Teknisi: ', '').replaceAll('Pelapor: ', ''),
        time: _commentTime(raw),
        isTeknisi: isTeknisi,
      );
    }).toList();
  }

  String _commentTime(String raw) {
    switch (raw) {
      case 'Pelapor: Tolong segera dibantu, ini mengganggu pekerjaan kami.':
        return '6 Apr 2025 · 08:35';
      case 'Teknisi: Sedang saya analisis penyebabnya.':
        return '6 Apr 2025 · 09:20';
      case 'Teknisi: Sedang saya cek di database.':
        return '6 Apr 2025 · 08:50';
      case 'Teknisi: Masalah sudah ditemukan, akan diupdate di versi berikutnya.':
        return '5 Apr 2025 · 14:10';
      case 'Pelapor: Terima kasih informasinya.':
        return '5 Apr 2025 · 14:25';
      case 'Teknisi: Tiket ditutup.':
        return '5 Apr 2025 · 15:00';
      default:
        return 'Baru saja';
    }
  }

  // ── BUILD KOMENTAR SECTION ──
  Widget _buildKomentar() {
    final t = widget.ticket;

    return AnimatedBuilder(
      animation: DataService.ticketNotifier,
      builder: (context, _) {
        final raw = DataService.getTicketComments(t.id);
        final comments = _buildComments(raw);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon: Icons.chat_bubble_outline,
              label: 'Komentar',
            ),
            const SizedBox(height: 10),
            if (comments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Belum ada komentar.',
                  style: TextStyle(fontSize: 12, color: _C.hint),
                ),
              )
            else
              ...comments.map((c) => _CommentBubble(comment: c)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      hintStyle: const TextStyle(fontSize: 13, color: _C.hint),
                      filled: true,
                      fillColor: _C.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendComment,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataService.ticketNotifier,
      builder: (context, _) {
        final t = DataService.getTicketById(widget.ticket.id) ?? widget.ticket;
        final prioColor = _priorityColor(t.priority);
        final progressValue = t.status == 'Selesai'
            ? 1.0
            : t.status == 'Dikerjakan'
            ? 0.65
            : 0.18;
        final progressLabel = t.status == 'Selesai'
            ? 'Selesai'
            : t.status == 'Dikerjakan'
            ? 'Sedang dikerjakan'
            : 'Menunggu teknisi';
        final progressTimeLeft = t.status == 'Selesai'
            ? 'Sudah selesai'
            : t.status == 'Dikerjakan'
            ? 'Est. selesai: 13:00'
            : 'Belum dimulai';

        return Scaffold(
          backgroundColor: _C.background,
          appBar: AppBar(
            backgroundColor: _C.primary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Detail Tiket',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Column(
                    children: [
                      _SectionCard(
                        noPadding: true,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: _C.primary,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _Chip(label: t.id, mono: true),
                                      const SizedBox(width: 8),
                                      _StatusChip(status: t.status),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    t.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _MetaPill(
                                          label: 'Prioritas',
                                          value: t.priority,
                                          dot: prioColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _MetaPill(
                                          label: 'Tanggal dibuat',
                                          value: t.date,
                                          dot: const Color(0xFF60A5FA),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _MetaPill(
                                          label: 'Teknisi',
                                          value: t.assignedTo ?? '-',
                                          dot: const Color(0xFF60A5FA),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _MetaPill(
                                          label: 'Estimasi',
                                          value: '1 hari kerja',
                                          dot: const Color(0xFFFBBF24),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionHeader(
                                    icon: Icons.description_outlined,
                                    label: 'Deskripsi masalah',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    t.description,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: _C.onSurfaceVariant,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      _Tag(
                                        label: t.reporter,
                                        color: _C.tagBlue,
                                        textColor: _C.primary,
                                      ),
                                      _Tag(
                                        label: t.priority,
                                        color: _C.tagRed,
                                        textColor: _C.error,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionHeader(
                              icon: Icons.tune_outlined,
                              label: 'Progress pengerjaan',
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  progressLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _C.muted,
                                  ),
                                ),
                                Text(
                                  '${(progressValue * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _C.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                minHeight: 6,
                                backgroundColor: _C.outline,
                                valueColor: const AlwaysStoppedAnimation(
                                  _C.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mulai: ${t.assignedAt ?? '09:15'}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _C.hint,
                                  ),
                                ),
                                Text(
                                  progressTimeLeft,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: t.status == 'Selesai'
                                        ? _C.green
                                        : _C.amber,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionHeader(
                              icon: Icons.history,
                              label: 'Riwayat aktivitas',
                            ),
                            const SizedBox(height: 12),
                            _Timeline(
                              items: [
                                _TimelineItem(
                                  title: 'Tiket dibuat',
                                  subtitle:
                                      'Oleh ${t.reporter} · ${t.date}, 08:30',
                                  done: true,
                                ),
                                _TimelineItem(
                                  title: 'Tiket diterima sistem',
                                  subtitle:
                                      'Tiket masuk ke antrian · ${t.date}, 08:31',
                                  done: true,
                                ),
                                _TimelineItem(
                                  title: 'Sedang dikerjakan',
                                  subtitle:
                                      'Oleh ${t.assignedTo ?? 'Teknisi'} · ${t.date}, 09:15',
                                  done: true,
                                  isActive: true,
                                ),
                                _TimelineItem(
                                  title: 'Selesai',
                                  subtitle: 'Menunggu penyelesaian',
                                  done: t.status == 'Selesai',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionHeader(
                              icon: Icons.camera_alt_outlined,
                              label: 'Bukti foto pengerjaan',
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _pickPhotos,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: _photos.length >= 5
                                        ? _C.outline
                                        : _C.primary.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 26,
                                      color: _photos.length >= 5
                                          ? _C.hint
                                          : _C.primary,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _photos.length >= 5
                                          ? 'Batas 5 foto tercapai'
                                          : 'Ketuk untuk upload foto',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _photos.length >= 5
                                            ? _C.hint
                                            : _C.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_photos.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _photos.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemBuilder: (_, i) => Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(_photos[i].path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () =>
                                            setState(() => _photos.removeAt(i)),
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(child: _buildKomentar()),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (t.status == 'Dikerjakan')
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _confirmSelesai,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Konfirmasi Selesai',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================================
//  REUSABLE WIDGETS
// =====================================================================

class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool noPadding;
  const _SectionCard({required this.child, this.noPadding = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: noPadding ? EdgeInsets.zero : const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E1EB), width: 0.5),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _C.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _C.onSurface,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool mono;
  const _Chip({required this.label, this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: mono ? 'monospace' : null,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    // FIX: declare variables first, then assign in switch
    Color bg;
    Color fg;
    bool pulse = false;

    switch (status) {
      case 'Dikerjakan':
        bg = const Color(0xFFFFA500);
        fg = Colors.white;
        pulse = true;
        break;
      case 'Selesai':
        bg = const Color(0xFF166534);
        fg = Colors.white;
        break;
      case 'Terbuka':
        bg = const Color(0xFFEEF2FF);
        fg = _C.primary;
        break;
      default:
        bg = const Color(0xFFE3E1EB);
        fg = _C.muted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse) ...[_PulseDot(), const SizedBox(width: 4)],
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween(begin: 1.0, end: 0.3).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    ),
  );
}

class _MetaPill extends StatelessWidget {
  final String label;
  final String value;
  final Color dot;
  const _MetaPill({
    required this.label,
    required this.value,
    required this.dot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xAAFFFFFF)),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Tag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

// ── TIMELINE ──
class _TimelineItem {
  final String title;
  final String subtitle;
  final bool done;
  final bool isActive;
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.done,
    this.isActive = false,
  });
}

class _Timeline extends StatelessWidget {
  final List<_TimelineItem> items;
  const _Timeline({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        final isLast = i == items.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: item.done ? _C.primary : _C.outline,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.done
                            ? (item.isActive ? Icons.build : Icons.check)
                            : Icons.radio_button_unchecked,
                        size: 14,
                        color: item.done ? Colors.white : _C.hint,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: _C.outlineLight,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: item.done ? _C.primary : _C.hint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(fontSize: 11, color: _C.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── COMMENTS ──
class _Comment {
  final String role;
  final String text;
  final String time;
  final bool isTeknisi;
  _Comment({
    required this.role,
    required this.text,
    required this.time,
    required this.isTeknisi,
  });
}

class _CommentBubble extends StatelessWidget {
  final _Comment comment;
  const _CommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    final bg = comment.isTeknisi ? _C.commentBlue : _C.commentGreen;
    final borderColor = comment.isTeknisi ? _C.primary : _C.green;
    final roleColor = comment.isTeknisi ? _C.primary : _C.green;
    final icon = comment.isTeknisi
        ? Icons.build_outlined
        : Icons.person_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: roleColor),
              const SizedBox(width: 4),
              Text(
                comment.role,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: roleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment.text,
            style: const TextStyle(
              fontSize: 12,
              color: _C.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              comment.time,
              style: const TextStyle(fontSize: 10, color: _C.hint),
            ),
          ),
        ],
      ),
    );
  }
}
