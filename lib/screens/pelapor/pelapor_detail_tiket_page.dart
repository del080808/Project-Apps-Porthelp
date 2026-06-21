import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/ticket_model.dart';
import '../../services/data_service.dart';
import '../../../core/theme/app_theme.dart';

class PelaporDetailTiketPage extends StatefulWidget {
  final Ticket ticket;

  const PelaporDetailTiketPage({super.key, required this.ticket});

  @override
  State<PelaporDetailTiketPage> createState() => _PelaporDetailTiketPageState();
}

class _PelaporDetailTiketPageState extends State<PelaporDetailTiketPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _ratingCommentController =
      TextEditingController();
  late Ticket _ticket;
  final ImagePicker _imagePicker = ImagePicker();

  // ── State: Bukti Penyelesaian ──
  final List<Uint8List> _buktiFotoBytes = [];
  bool _proofSubmitted = false;

  // ── State: Rating ──
  int _rating = 0; // 0 = belum pilih
  bool _ratingSubmitted = false;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    DataService.ensureTicketLoaded(_ticket);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _ratingCommentController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  // Helper
  // ─────────────────────────────────────────
  bool get _isStatusSelesai => _ticket.status == 'Selesai';

  bool get _showRatingSection =>
      _isStatusSelesai &&
      (_proofSubmitted || DataService.hasPelaporProof(_ticket.id)) &&
      DataService.hasTicketProof(_ticket.id);

  List<String> get _proofPhotos => DataService.getTicketProofPhotos(_ticket.id);

  String _getEstimasi() {
    switch (_ticket.priority.toLowerCase()) {
      case 'critical':
        return '4 jam kerja';
      case 'high':
        return '1 hari kerja';
      case 'medium':
        return '3 hari kerja';
      default:
        return '5 hari kerja';
    }
  }

  List<Map<String, dynamic>> _getRiwayatAktivitas() {
    final dateCreated = _ticket.date;
    final dateAssigned = _ticket.assignedAt ?? '-';
    final dateCompleted = _ticket.completedAt ?? '-';

    return [
      {
        'title': 'Tiket Dibuat',
        'description': 'Oleh ${_ticket.reporter}',
        'time': dateCreated,
        'done': true,
      },
      {
        'title': 'Tiket Diterima Sistem',
        'description': 'Tiket masuk ke antrian',
        'time': dateCreated,
        'done': true,
      },
      {
        'title': 'Sedang Dikerjakan',
        'description': _ticket.assignedTo != null
            ? 'Oleh ${_ticket.assignedTo}'
            : 'Menunggu teknisi',
        'time': _ticket.status == 'Dikerjakan' || _ticket.status == 'Selesai'
            ? dateAssigned
            : '-',
        'done': _ticket.status == 'Dikerjakan' || _ticket.status == 'Selesai',
      },
      {
        'title': 'Selesai',
        'description': _ticket.status == 'Selesai'
            ? 'Diselesaikan oleh ${_ticket.assignedTo ?? "teknisi"}'
            : 'Menunggu penyelesaian',
        'time': _ticket.status == 'Selesai' ? dateCompleted : '-',
        'done': _ticket.status == 'Selesai',
      },
    ];
  }

  Color _getStatusColor() {
    if (_ticket.status.contains('Selesai')) return Colors.green;
    if (_ticket.status.contains('Dikerjakan')) return Colors.orange;
    if (_ticket.status.contains('Terbuka')) return Colors.blue;
    return Colors.grey;
  }

  Color _getPriorityColor() {
    switch (_ticket.priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  // ─────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────
  void _kirimKomentar() {
    if (_commentController.text.trim().isEmpty) return;
    final commentText = 'Pelapor: ${_commentController.text.trim()}';
    setState(() {
      DataService.addTicketComment(_ticket.id, commentText);
      _commentController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Komentar berhasil dikirim!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _uploadFoto() async {
    if (!_isStatusSelesai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bukti penyelesaian baru bisa diunggah setelah tiket selesai.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!DataService.hasTicketProof(_ticket.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Menunggu teknisi mengirim bukti pengerjaan terlebih dahulu.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_proofSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti sudah dikirim, silakan tunggu verifikasi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_buktiFotoBytes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cukup 1 foto bukti untuk dikirim.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedImage == null) return;

    final imageBytes = await pickedImage.readAsBytes();

    if (!mounted) return;

    setState(() {
      _buktiFotoBytes.add(imageBytes);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto bukti berhasil diunggah.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitBuktiPenyelesaian() {
    if (!_isStatusSelesai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti hanya bisa dikirim setelah tiket selesai.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_buktiFotoBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan upload foto bukti terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!DataService.hasTicketProof(_ticket.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti pengerjaan dari teknisi belum tersedia.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_proofSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti sudah dikirim ke teknisi/admin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // persist bukti pelapor ke DataService as file path so other screens can access
    try {
      final tmpDir = Directory.systemTemp;
      final file = File(
        '${tmpDir.path}/${_ticket.id}_pelapor_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      file.writeAsBytesSync(_buktiFotoBytes.first);
      DataService.addPelaporProofPhotos(_ticket.id, [file.path]);
    } catch (_) {
      // ignore write errors for now; still mark submitted locally
    }

    setState(() {
      _proofSubmitted = true;
      _rating = 0;
      _ratingSubmitted = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bukti berhasil dikirim ke teknisi/admin.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitRating() {
    if (!_showRatingSection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kirim bukti penyelesaian terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih rating terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    DataService.submitTicketRating(
      _ticket.id,
      _rating.toDouble(),
      _ratingCommentController.text.trim(),
    );
    setState(() => _ratingSubmitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rating $_rating bintang berhasil dikirim!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _konfirmasiSelesai() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Selesai'),
        content: const Text(
          'Apakah tiket ini sudah selesai dan sesuai dengan yang Anda harapkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Persist confirmation via DataService so all screens update
              DataService.confirmTicketCompletionByPelapor(_ticket.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terima kasih! Tiket telah ditutup.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );
  }

  void _batalkanTiket() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Tiket?'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan tiket ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _ticket = _ticket.copyWith(status: 'Dibatalkan'));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tiket telah dibatalkan.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataService.ticketNotifier,
      builder: (context, _) {
        // refresh local ticket from service if available
        _ticket = DataService.getTicketById(_ticket.id) ?? _ticket;
        final riwayat = _getRiwayatAktivitas();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Tiket'),
            centerTitle: true,
            backgroundColor: AppPalette.primary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCard(child: _buildInfoUtama()),
                const SizedBox(height: 16),
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat Aktivitas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(riwayat.length, (index) {
                        final item = riwayat[index];
                        final isDone = item['done'] as bool;
                        final isLast = index == riwayat.length - 1;
                        final isCurrent =
                            isDone &&
                            (isLast || !(riwayat[index + 1]['done'] as bool));
                        return _TimelineItem(
                          title: item['title'] as String,
                          description: item['description'] as String,
                          time: item['time'] as String,
                          isDone: isDone,
                          isCurrent: isCurrent,
                          isLast: isLast,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(child: _buildBuktiPenyelesaian()),
                const SizedBox(height: 16),
                if (_showRatingSection) ...[
                  _buildCard(child: _buildRatingTeknisi()),
                  const SizedBox(height: 16),
                ],
                _buildCard(child: _buildKomentar()),
                const SizedBox(height: 16),
                if (_ticket.status == 'Dikerjakan')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _konfirmasiSelesai,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Konfirmasi Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (_ticket.status == 'Terbuka') ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _batalkanTiket,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Batalkan Tiket'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────
  // Section Builders
  // ─────────────────────────────────────────

  Widget _buildInfoUtama() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _ticket.id,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _ticket.status,
                style: TextStyle(
                  fontSize: 11,
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _ticket.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _DetailItem(
          label: 'Prioritas',
          value: _ticket.priority,
          color: _getPriorityColor(),
        ),
        const SizedBox(height: 12),
        _DetailItem(
          label: 'Tanggal Dibuat',
          value: _ticket.date,
          color: Colors.grey.shade700,
        ),
        const SizedBox(height: 12),
        if (_ticket.assignedTo != null) ...[
          _DetailItem(
            label: 'Teknisi',
            value: _ticket.assignedTo!,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
        ],
        _DetailItem(
          label: 'Estimasi',
          value: _getEstimasi(),
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          'Deskripsi Masalah',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _ticket.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ── Bukti Penyelesaian (dari Teknisi) + Konfirmasi Penerimaan (oleh Pelapor) ──
  Widget _buildBuktiPenyelesaian() {
    final proofPhotos = _proofPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bukti Penyelesaian',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Dokumentasi yang diunggah oleh teknisi',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 12),
        if (!_isStatusSelesai)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, color: Colors.orange.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bukti penyelesaian dari teknisi akan muncul setelah tiket selesai.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.image_outlined, color: Colors.blue.shade400),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    proofPhotos.isNotEmpty
                        ? 'Foto bukti dari teknisi telah tersedia. Silakan verifikasi pekerjaan di bawah.'
                        : 'Tiket selesai, tetapi bukti pengerjaan dari teknisi belum diunggah.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (proofPhotos.isNotEmpty) ...[
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: proofPhotos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (_, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(proofPhotos[index]), fit: BoxFit.cover),
              ),
            ),
          ],
        ],
        if (_isStatusSelesai) ...[
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Konfirmasi Penerimaan Kerja',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Unggah foto sebagai bukti bahwa Anda telah menerima dan memverifikasi pekerjaan ini',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          // Show pelapor's uploaded confirmation photo if available (local or stored)
          Builder(
            builder: (context) {
              final pelaporPaths = DataService.getPelaporProofPhotos(
                _ticket.id,
              );
              final hasStored = pelaporPaths.isNotEmpty;
              if (_buktiFotoBytes.isEmpty && !hasStored) {
                return GestureDetector(
                  onTap: _proofSubmitted ? null : _uploadFoto,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 36,
                          color: AppPalette.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload Foto Konfirmasi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Foto sebagai tanda bahwa\npekerjaan telah Anda terima',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Prefer showing local bytes first if present
              if (_buktiFotoBytes.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 1.4,
                          child: Image.memory(
                            _buktiFotoBytes.first,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _proofSubmitted
                                  ? 'Konfirmasi penerimaan sudah dikirim.'
                                  : 'Foto siap dikirim sebagai konfirmasi.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              // Show stored pelapor file
              if (hasStored) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 1.4,
                          child: Image.file(
                            File(pelaporPaths.first),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Konfirmasi penerimaan sudah dikirim.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _proofSubmitted ? null : _submitBuktiPenyelesaian,
              icon: const Icon(Icons.send),
              label: Text(
                _proofSubmitted
                    ? 'Konfirmasi Sudah Dikirim'
                    : 'Kirim Konfirmasi Penerimaan',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _proofSubmitted
                ? 'Konfirmasi sudah dikirim dan menunggu verifikasi.'
                : 'Setelah upload foto, tekan tombol kirim untuk mengonfirmasi penerimaan kerja.',
            style: TextStyle(fontSize: 11, color: Colors.blue.shade400),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.blue.shade400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Kirim konfirmasi penerimaan sebelum memberikan penilaian ke teknisi.',
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade400),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Rating Teknisi ──
  Widget _buildRatingTeknisi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Berikan Penilaian untuk Teknisi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Bagaimana kinerja teknisi dalam menyelesaikan tiket ini?',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        if (!_showRatingSection) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _isStatusSelesai
                  ? 'Rating akan muncul setelah bukti dikirim ke teknisi/admin.'
                  : 'Rating akan tersedia setelah status selesai dan bukti pekerjaan dikirim.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: _ratingSubmitted
                    ? null
                    : () => setState(() => _rating = starIndex),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    size: 36,
                    color: starIndex <= _rating
                        ? const Color(0xFFFBBF24)
                        : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
          if (_rating > 0) ...[
            const SizedBox(height: 4),
            Text(
              _ratingLabel(_rating),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (!_ratingSubmitted) ...[
            TextField(
              controller: _ratingCommentController,
              maxLines: 2,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Tambahkan komentar (opsional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating > 0 ? _submitRating : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Kirim Penilaian'),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Penilaian Anda telah dikirim. Terima kasih!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_ratingCommentController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '"${_ratingCommentController.text.trim()}"',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ],
        ],
      ],
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Tidak Puas';
      case 2:
        return 'Tidak Puas';
      case 3:
        return 'Cukup';
      case 4:
        return 'Puas';
      case 5:
        return 'Sangat Puas';
      default:
        return '';
    }
  }

  // ── Komentar ──
  Widget _buildKomentar() {
    return AnimatedBuilder(
      animation: DataService.ticketNotifier,
      builder: (context, _) {
        final comments = DataService.getTicketComments(_ticket.id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Komentar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (comments.isNotEmpty)
              ...comments.map((comment) {
                final isTeknisi = comment.contains('Teknisi:');
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isTeknisi
                            ? Colors.blue.shade100
                            : Colors.green.shade100,
                        child: Text(
                          isTeknisi
                              ? (_ticket.assignedTo?.isNotEmpty == true
                                    ? _ticket.assignedTo![0].toUpperCase()
                                    : 'T')
                              : (_ticket.reporter.isNotEmpty
                                    ? _ticket.reporter[0].toUpperCase()
                                    : 'P'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isTeknisi
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isTeknisi
                                ? Colors.blue.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTeknisi
                                    ? (_ticket.assignedTo ?? 'Teknisi')
                                    : 'Anda',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isTeknisi
                                      ? Colors.blue.shade700
                                      : Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment
                                    .replaceAll('Teknisi: ', '')
                                    .replaceAll('Pelapor: ', ''),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              })
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Belum ada komentar',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar Anda...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _kirimKomentar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Kirim'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────
  // Shared card wrapper
  // ─────────────────────────────────────────
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ══════════════════════════════════════════
// TIMELINE ITEM WIDGET
// ══════════════════════════════════════════
class _TimelineItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.description,
    required this.time,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    Color circleColor;
    if (isDone && !isCurrent) {
      circleColor = const Color(0xFF1A237E);
    } else if (isCurrent) {
      circleColor = const Color(0xFF1A237E);
    } else {
      circleColor = Colors.grey.shade300;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                  border: isCurrent && !isDone
                      ? Border.all(color: const Color(0xFF1A237E), width: 2)
                      : null,
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : isCurrent
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF1A237E)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDone
                        ? const Color(0xFF1A237E)
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (time != '-') ...[
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════
// DETAIL ITEM WIDGET
// ══════════════════════════════════════════
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
