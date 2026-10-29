import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catatan.dart';
import '../viewmodels/catatan_view_model.dart';

// ============================================================
// WARNA APLIKASI
// ============================================================

class _Warna {
  static const navy = Color(0xFF0B2259);
  static const blue = Color(0xFF1765D8);
  static const yellow = Color(0xFFFFC928);
  static const background = Color(0xFFF3F6FC);
  static const border = Color(0xFFE1E8F2);
  static const secondary = Color(0xFF697991);
}

// ============================================================
// HALAMAN CATATAN LOKAL
// ============================================================

class CatatanLokalScreen extends StatelessWidget {
  const CatatanLokalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CatatanViewModel()..muatCatatan(),
      child: const _CatatanLokalView(),
    );
  }
}

class _CatatanLokalView extends StatelessWidget {
  const _CatatanLokalView();

  Future<void> _bukaForm(
    BuildContext context, {
    Catatan? catatan,
  }) async {
    final viewModel = context.read<CatatanViewModel>();

    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _FormCatatanScreen(
          catatan: catatan,
          viewModel: viewModel,
        ),
      ),
    );

    if (!context.mounted) return;

    if (berhasil == true) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              catatan == null
                  ? 'Catatan berhasil disimpan ke SQLite.'
                  : 'Catatan berhasil diperbarui.',
            ),
            backgroundColor: _Warna.navy,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _hapus(
    BuildContext context,
    Catatan catatan,
  ) async {
    final viewModel = context.read<CatatanViewModel>();

    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Catatan?'),
          content: Text(
            'Catatan "${catatan.judul}" '
            'akan dihapus secara permanen.\n\n'
            'Apakah kamu yakin?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ya, Hapus'),
            ),
          ],
        );
      },
    );

    if (setuju != true) return;

    try {
      await viewModel.hapusCatatan(catatan.id!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil dihapus.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _bukaDetail(
    BuildContext context,
    Catatan catatan,
  ) {
    final viewModel = context.read<CatatanViewModel>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DetailCatatanScreen(
          catatanId: catatan.id!,
          viewModel: viewModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CatatanViewModel>();

    return Scaffold(
      backgroundColor: _Warna.background,
      appBar: AppBar(
        title: const Text(
          'Catatan Perkuliahan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: _Warna.navy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Muat ulang catatan',
            onPressed: viewModel.isLoading
                ? null
                : viewModel.muatCatatan,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(context),
        backgroundColor: _Warna.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Catatan'),
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.muatCatatan,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _Warna.navy,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    color: _Warna.yellow,
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Catatan Perkuliahan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Simpan materi kuliah secara lokal '
                    'dan akses kembali tanpa internet.',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(
                  Icons.storage_rounded,
                  color: _Warna.blue,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Daftar Catatan Lokal',
                    style: TextStyle(
                      color: _Warna.navy,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${viewModel.catatan.length} catatan',
                  style: const TextStyle(
                    color: _Warna.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (viewModel.error != null)
              _PesanKosong(
                icon: Icons.error_outline_rounded,
                title: 'Gagal Memuat Catatan',
                subtitle: viewModel.error!,
              )
            else if (viewModel.catatan.isEmpty)
              const _PesanKosong(
                icon: Icons.note_add_outlined,
                title: 'Belum Ada Catatan',
                subtitle:
                    'Tekan Tambah Catatan untuk menyimpan '
                    'materi pertama ke SQLite.',
              )
            else
              for (final item in viewModel.catatan)
                _KartuCatatan(
                  catatan: item,
                  onDetail: () => _bukaDetail(context, item),
                  onEdit: () => _bukaForm(
                    context,
                    catatan: item,
                  ),
                  onDelete: () => _hapus(context, item),
                ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// KARTU CATATAN
// ============================================================

class _KartuCatatan extends StatelessWidget {
  const _KartuCatatan({
    required this.catatan,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
  });

  final Catatan catatan;
  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _Warna.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              catatan.mataKuliah,
              style: const TextStyle(
                color: _Warna.blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              catatan.judul,
              style: const TextStyle(
                color: _Warna.navy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              catatan.isi,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _Warna.secondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: _Warna.border),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: _Warna.secondary,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _tanggalTampil(catatan.tanggal),
                    style: const TextStyle(
                      color: _Warna.secondary,
                      fontSize: 11,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Lihat detail',
                  onPressed: onDetail,
                  icon: const Icon(
                    Icons.visibility_outlined,
                    color: _Warna.blue,
                  ),
                ),
                IconButton(
                  tooltip: 'Ubah catatan',
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: _Warna.navy,
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus catatan',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DETAIL CATATAN
// ============================================================

class _DetailCatatanScreen extends StatelessWidget {
  const _DetailCatatanScreen({
    required this.catatanId,
    required this.viewModel,
  });

  final int catatanId;
  final CatatanViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: _DetailCatatanView(catatanId: catatanId),
    );
  }
}

class _DetailCatatanView extends StatelessWidget {
  const _DetailCatatanView({
    required this.catatanId,
  });

  final int catatanId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatatanViewModel>();

    Catatan? catatan;

    for (final item in vm.catatan) {
      if (item.id == catatanId) {
        catatan = item;
        break;
      }
    }

    return Scaffold(
      backgroundColor: _Warna.background,
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        backgroundColor: _Warna.navy,
        foregroundColor: Colors.white,
      ),
      body: catatan == null
          ? const Center(
              child: Text('Catatan tidak ditemukan.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _Warna.navy,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        color: _Warna.yellow,
                        size: 30,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        catatan.judul,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        catatan.mataKuliah,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: _Warna.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Isi Catatan',
                        style: TextStyle(
                          color: _Warna.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 13),
                      SelectableText(
                        catatan.isi,
                        style: const TextStyle(
                          height: 1.65,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      Text(
                        'Dibuat: ${_tanggalTampil(catatan.tanggal)}',
                        style: const TextStyle(
                          color: _Warna.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _Warna.blue,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () {
                    Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _FormCatatanScreen(
                          catatan: catatan,
                          viewModel: context.read<CatatanViewModel>(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Ubah Catatan'),
                ),
              ],
            ),
    );
  }
}

// ============================================================
// FORM TAMBAH DAN EDIT CATATAN
// ============================================================

class _FormCatatanScreen extends StatefulWidget {
  const _FormCatatanScreen({
    required this.viewModel,
    this.catatan,
  });

  final CatatanViewModel viewModel;
  final Catatan? catatan;

  @override
  State<_FormCatatanScreen> createState() {
    return _FormCatatanScreenState();
  }
}

class _FormCatatanScreenState extends State<_FormCatatanScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _mataKuliah;
  late final TextEditingController _judul;
  late final TextEditingController _isi;

  bool _menyimpan = false;

  bool get _modeEdit => widget.catatan != null;

  @override
  void initState() {
    super.initState();

    _mataKuliah = TextEditingController(
      text: widget.catatan?.mataKuliah ?? '',
    );

    _judul = TextEditingController(
      text: widget.catatan?.judul ?? '',
    );

    _isi = TextEditingController(
      text: widget.catatan?.isi ?? '',
    );
  }

  @override
  void dispose() {
    _mataKuliah.dispose();
    _judul.dispose();
    _isi.dispose();
    super.dispose();
  }

  String? _validasiWajib(String? value, String nama) {
    if (value == null || value.trim().isEmpty) {
      return '$nama wajib diisi.';
    }

    return null;
  }

  Future<void> _simpan() async {
    if (_menyimpan) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _menyimpan = true;
    });

    try {
      final sekarang = DateTime.now().toIso8601String();

      final catatan = Catatan(
        id: widget.catatan?.id,
        mataKuliah: _mataKuliah.text.trim(),
        judul: _judul.text.trim(),
        isi: _isi.text.trim(),
        tanggal: widget.catatan?.tanggal ?? sekarang,
      );

      if (_modeEdit) {
        await widget.viewModel.ubahCatatan(catatan);
      } else {
        await widget.viewModel.tambahCatatan(catatan);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan catatan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _menyimpan = false;
        });
      }
    }
  }

  InputDecoration _dekorasi(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _Warna.blue),
      filled: true,
      fillColor: _Warna.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _Warna.border,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Warna.background,
      appBar: AppBar(
        title: Text(
          _modeEdit ? 'Ubah Catatan' : 'Tambah Catatan',
        ),
        backgroundColor: _Warna.navy,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode:
            AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _Warna.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _modeEdit
                        ? 'Perbarui Catatan'
                        : 'Catatan Baru',
                    style: const TextStyle(
                      fontSize: 20,
                      color: _Warna.navy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Semua kolom wajib diisi. '
                    'Data disimpan di SQLite Android.',
                    style: TextStyle(
                      color: _Warna.secondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 22),

                  TextFormField(
                    controller: _mataKuliah,
                    enabled: !_menyimpan,
                    maxLength: 100,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: _dekorasi(
                      'Mata Kuliah *',
                      Icons.school_outlined,
                    ),
                    validator: (value) {
                      return _validasiWajib(
                        value,
                        'Mata kuliah',
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _judul,
                    enabled: !_menyimpan,
                    maxLength: 150,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: _dekorasi(
                      'Judul Catatan *',
                      Icons.title_rounded,
                    ),
                    validator: (value) {
                      return _validasiWajib(
                        value,
                        'Judul catatan',
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _isi,
                    enabled: !_menyimpan,
                    minLines: 5,
                    maxLines: 10,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Isi Catatan *',
                      alignLabelWithHint: true,
                      hintText:
                          'Tulis materi perkuliahan di sini...',
                      filled: true,
                      fillColor: _Warna.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    validator: (value) {
                      return _validasiWajib(
                        value,
                        'Isi catatan',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              style: FilledButton.styleFrom(
                backgroundColor: _Warna.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(17),
              ),
              icon: _menyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _menyimpan
                    ? 'Menyimpan...'
                    : _modeEdit
                        ? 'Simpan Perubahan'
                        : 'Simpan Catatan',
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: _menyimpan
                  ? null
                  : () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// KOMPONEN KONDISI KOSONG / ERROR
// ============================================================

class _PesanKosong extends StatelessWidget {
  const _PesanKosong({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Warna.border),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 49,
            color: _Warna.blue,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _Warna.navy,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _Warna.secondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FORMAT TANGGAL INDONESIA
// ============================================================

String _tanggalTampil(String input) {
  final tanggal = DateTime.tryParse(input);

  if (tanggal == null) return input;

  const bulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return '${tanggal.day} '
      '${bulan[tanggal.month]} '
      '${tanggal.year}';
}