import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../services/data_service.dart';

class BuatTiketPage extends StatefulWidget {
  final VoidCallback? onSelesai;

  const BuatTiketPage({super.key, this.onSelesai});

  @override
  State<BuatTiketPage> createState() => _BuatTiketPageState();
}

class _BuatTiketPageState extends State<BuatTiketPage> {
  String _category = 'Hardware';
  String _priority = 'Medium';
  final _locationController = TextEditingController();
  final _assetController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _pickedFile;

  final _categories = ['Hardware', 'Software', 'Network', 'Lainnya'];
  final _priorities = ['Low', 'Medium', 'High', 'Critical'];

  final Map<String, List<String>> _subCategoryMap = {
    'Hardware': ['Laptop / Desktop', 'Printer', 'Monitor', 'Keyboard / Mouse'],
    'Software': ['Antivirus', 'Office', 'OS', 'Aplikasi Lainnya'],
    'Network': ['WiFi', 'LAN', 'VPN', 'Internet'],
    'Lainnya': ['Lainnya'],
  };

  late String _subCategory = _subCategoryMap[_category]!.first;

  @override
  void dispose() {
    _locationController.dispose();
    _assetController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    _locationController.clear();
    _assetController.clear();
    _descController.clear();
    setState(() {
      _category = 'Hardware';
      _subCategory = _subCategoryMap['Hardware']!.first;
      _priority = 'Medium';
      _pickedFile = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final f = await picker.pickImage(source: ImageSource.camera);
                if (f != null) setState(() => _pickedFile = File(f.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final f = await picker.pickImage(source: ImageSource.gallery);
                if (f != null) setState(() => _pickedFile = File(f.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _kembaliKeBeranda() {
    if (widget.onSelesai != null) {
      widget.onSelesai!();
    }
  }

  void _konfirmasiBatal() {
    final adaIsi =
        _titleController.text.trim().isNotEmpty ||
        _locationController.text.trim().isNotEmpty ||
        _descController.text.trim().isNotEmpty ||
        _assetController.text.trim().isNotEmpty ||
        _pickedFile != null;

    if (!adaIsi) {
      _kembaliKeBeranda();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Buang Formulir?'),
        content: const Text(
          'Semua isian yang sudah Anda tulis akan hilang. Yakin ingin keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Lanjutkan Mengisi',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _kembaliKeBeranda();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Ya, Buang'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) {
      _showValidationSnackBar('Judul tiket tidak boleh kosong');
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      _showValidationSnackBar('Lokasi / kantor tidak boleh kosong');
      return;
    }
    if (_descController.text.trim().isEmpty) {
      _showValidationSnackBar('Deskripsi masalah tidak boleh kosong');
      return;
    }

    final ticket = Ticket(
      id: DataService.nextTicketId(),
      title: _titleController.text.trim(),
      description:
          'Kategori: $_category | Sub-kategori: $_subCategory | Lokasi: ${_locationController.text.trim()} | Aset: ${_assetController.text.trim()}\n\n${_descController.text.trim()}',
      priority: _priority,
      status: 'Terbuka',
      date: DateTime.now().toIso8601String().split('T').first,
      assignedTo: null,
      reporter: 'Anda',
      comments: const [],
      deadline: DateTime.now().add(const Duration(days: 3)),
      isOverdue: false,
    );

    DataService.addTicket(ticket);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 52,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tiket Berhasil Dikirim!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tiket Anda sedang menunggu untuk ditangani oleh teknisi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                  _kembaliKeBeranda();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidationSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSubCategories = _subCategoryMap[_category]!;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text('Buat Tiket Baru'),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _konfirmasiBatal,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Jelaskan masalah yang Anda alami dan kami akan segera menanganinya.",
              style: TextStyle(fontSize: 13, color: AppPalette.textSecondary),
            ),
            const SizedBox(height: 20),

            _label('Kategori'),
            _dropdown(_category, _categories, (v) {
              if (v == null) return;
              setState(() {
                _category = v;
                _subCategory = _subCategoryMap[v]!.first;
              });
            }),
            const SizedBox(height: 12),

            _label('Sub-kategori'),
            _dropdown(
              _subCategory,
              activeSubCategories,
              (v) => setState(() => _subCategory = v!),
            ),
            const SizedBox(height: 16),

            _label('Tingkat Prioritas'),
            Row(
              children: _priorities.map((p) {
                final selected = _priority == p;
                Color color = Colors.blue;
                if (p == 'High') color = Colors.orange;
                if (p == 'Critical') color = Colors.red;
                if (p == 'Low') color = Colors.green;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? color : AppPalette.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? color : AppPalette.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            p,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppPalette.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            _label('Lokasi / Kantor *'),
            _textField(_locationController, 'Contoh: Lantai 4, Meja 412'),
            const SizedBox(height: 12),

            _label('Nomor Aset'),
            _textField(_assetController, 'Contoh: ASSET-9921'),
            const SizedBox(height: 12),

            _label('Judul Masalah *'),
            _textField(
              _titleController,
              'Jelaskan secara singkat masalah yang Anda alami',
            ),
            const SizedBox(height: 12),

            _label('Deskripsi Rinci *'),
            TextField(
              controller: _descController,
              maxLines: 4,
              maxLength: 500,
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) {
                    final isNearLimit = currentLength > 400;
                    return Text(
                      '$currentLength / $maxLength',
                      style: TextStyle(
                        fontSize: 11,
                        color: isNearLimit
                            ? Colors.orange.shade700
                            : Colors.grey.shade500,
                        fontWeight: isNearLimit
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    );
                  },
              decoration: InputDecoration(
                hintText:
                    'Berikan detail lebih lanjut, kode error, atau apa yang sedang Anda lakukan ketika terjadi masalah...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: AppPalette.textSecondary.withValues(
                    alpha: 0.7,
                  ), // ← fix
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppPalette.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppPalette.border),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '* Wajib diisi',
              style: TextStyle(
                fontSize: 11,
                color: AppPalette.textSecondary.withOpacity(0.7), // ← fix
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPalette.border),
                ),
                child: _pickedFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _pickedFile!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _pickedFile = null),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 36,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Unggah Foto Pendukung',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pilih dari kamera atau galeri  •  Maks 1 foto  •  Maks 10MB',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppPalette.textSecondary.withValues(
                                alpha: 0.7,
                              ), // ← fix
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kirim Tiket',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: _konfirmasiBatal,
                child: Text(
                  'Batal dan Buang',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    final isRequired = text.endsWith('*');
    final labelText = isRequired
        ? text.substring(0, text.length - 1).trim()
        : text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: isRequired
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) => TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
    ),
  );

  Widget _dropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String>(
    initialValue: value, // ← fix deprecated
    onChanged: onChanged,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
    ),
    items: items
        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
        .toList(),
  );
}
