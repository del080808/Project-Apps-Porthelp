import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../services/data_service.dart';
import 'pelapor_detail_tiket_page.dart';
import 'widgets/pelapor_ticket_card.dart';

class PelaporTiketSayaPage extends StatefulWidget {
  const PelaporTiketSayaPage({super.key});

  @override
  State<PelaporTiketSayaPage> createState() => _PelaporTiketSayaPageState();
}

class _PelaporTiketSayaPageState extends State<PelaporTiketSayaPage> {
  String _searchQuery = '';
  String _filterStatus = 'Semua';

  // ──────────────────────────────────────────────────
  // PERBAIKAN 2: Tambah state untuk sort
  // Default: 'Terbaru' — tiket paling baru tampil duluan
  // ──────────────────────────────────────────────────
  String _sortBy = 'Terbaru';
  final List<String> _sortOptions = ['Terbaru', 'Terlama', 'Prioritas Tertinggi'];

  // ──────────────────────────────────────────────────
  // PERBAIKAN 1: Tambah controller untuk search bar
  // agar bisa di-clear secara programatik lewat tombol X
  // ──────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();

  // ──────────────────────────────────────────────────
  // PERBAIKAN 3: Hapus 'late List<Ticket> tickets' dan initState.
  // Ganti dengan getter langsung ke DataService agar data
  // selalu fresh setiap kali halaman di-rebuild.
  // ──────────────────────────────────────────────────
  List<Ticket> get tickets => DataService.getPelaporSampleTickets();

  @override
  void dispose() {
    // PERBAIKAN 1: Dispose controller agar tidak memory leak
    _searchController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────
  // PERBAIKAN 2 & 3: Getter _filteredTickets sekarang
  // juga menerapkan sort setelah filter selesai.
  // ──────────────────────────────────────────────────
  List<Ticket> get _filteredTickets {
    // Step 1: Filter berdasarkan search query dan status
    final filtered = tickets.where((ticket) {
      final matchesSearch =
          ticket.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ticket.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          ticket.id.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _filterStatus == 'Semua' ||
          ticket.status.toLowerCase().contains(_filterStatus.toLowerCase());

      return matchesSearch && matchesStatus;
    }).toList();

    // Step 2: Sort berdasarkan pilihan user
    switch (_sortBy) {
      case 'Terlama':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Prioritas Tertinggi':
        // Critical=0, High=1, Medium=2, Low=3 (makin kecil = makin tinggi)
        const priorityOrder = {
          'Critical': 0,
          'High': 1,
          'Medium': 2,
          'Low': 3,
        };
        filtered.sort(
          (a, b) => (priorityOrder[a.priority] ?? 9)
              .compareTo(priorityOrder[b.priority] ?? 9),
        );
        break;
      case 'Terbaru':
      default:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final statusFilters = ['Semua', 'Terbuka', 'Dikerjakan', 'Selesai'];
    final filteredList = _filteredTickets;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Tiket Saya',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppPalette.secondary.withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search + Filter ──
          Container(
            color: AppPalette.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                // ── Search bar ──
                // ──────────────────────────────────────────────────
                // PERBAIKAN 1: Tambah controller dan suffixIcon tombol
                // clear (X) yang muncul otomatis saat ada teks.
                // ──────────────────────────────────────────────────
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cari ID tiket atau judul masalah...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: AppPalette.textSecondary.withOpacity(0.7),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppPalette.textSecondary,
                    ),
                    // Tombol X muncul hanya saat ada teks, hilang kalau kosong
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            color: AppPalette.textSecondary,
                            tooltip: 'Hapus pencarian',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Filter chip horizontal scroll ──
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: statusFilters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = statusFilters[index];
                      final isSelected = _filterStatus == filter;
                      return GestureDetector(
                        onTap: () => setState(() => _filterStatus = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppPalette.primary
                                : AppPalette.mutedSurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppPalette.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // ──────────────────────────────────────────────────
                // PERBAIKAN 2: Bar info jumlah tiket + dropdown sort.
                // Tampil sebagai satu baris:
                //   kiri  → "3 tiket ditemukan"
                //   kanan → ikon sort + dropdown "Terbaru ▾"
                // ──────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredList.length} tiket ditemukan',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppPalette.textSecondary,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 16,
                          color: AppPalette.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        DropdownButton<String>(
                          value: _sortBy,
                          underline: const SizedBox(), // hapus garis bawah
                          isDense: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: AppPalette.primary,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppPalette.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          items: _sortOptions
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _sortBy = v);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── List Tiket ──
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 64,
                          color: AppPalette.border,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada tiket',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppPalette.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coba ubah filter atau buat tiket baru',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppPalette.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredList[index];
                      return PelaporTicketCard(
                        ticket: ticket,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PelaporDetailTiketPage(ticket: ticket),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}