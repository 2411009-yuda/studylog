import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

// ============================================================
// KONFIGURASI API DAN WARNA
// ============================================================

// Untuk emulator Android yang menggunakan ADB Reverse.
const String apiBaseUrl = 'http://192.168.1.106:8000/api';

class AppColors {
  static const Color navy = Color(0xFF071F57);
  static const Color blue = Color(0xFF1664D9);
  static const Color yellow = Color(0xFFFFCB32);
  static const Color background = Color(0xFFF4F7FC);
  static const Color white = Colors.white;
  static const Color text = Color(0xFF243047);
  static const Color muted = Color(0xFF748096);
  static const Color border = Color(0xFFE4EAF3);
  static const Color green = Color(0xFF16996C);
}

// ============================================================
// HELPER
// ============================================================

String safeText(dynamic value, {String fallback = '-'}) {
  if (value == null) return fallback;

  final text = value.toString().trim();

  return text.isEmpty ? fallback : text;
}

int safeInt(dynamic value) {
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String shortTime(dynamic value) {
  final text = safeText(value);

  if (text.length >= 5) {
    return text.substring(0, 5);
  }

  return text;
}

String dayName(int day) {
  const days = [
    '-',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  if (day < 1 || day > 7) return '-';

  return days[day];
}

String formatDate(String value) {
  final date = DateTime.tryParse(value);

  if (date == null) return '-';

  const months = [
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

  return '${date.day} ${months[date.month]} ${date.year}';
}

String errorMessage(Object error) {
  return error
      .toString()
      .replaceFirst('Exception: ', '')
      .replaceFirst('HttpException: ', '');
}

// ============================================================
// MODEL DETAIL MATA KULIAH
// ============================================================

class CourseDetailData {
  final int id;
  final String code;
  final String name;
  final int credits;
  final String className;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;
  final String lecturer;
  final String semester;

  const CourseDetailData({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.className,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.lecturer,
    required this.semester,
  });

  factory CourseDetailData.fromJson(Map<String, dynamic> json) {
    return CourseDetailData(
      id: safeInt(json['id']),
      code: safeText(json['course_code']),
      name: safeText(json['course_name']),
      credits: safeInt(json['credits']),
      className: safeText(json['class_name']),
      dayOfWeek: safeInt(json['day_of_week']),
      startTime: shortTime(json['start_time']),
      endTime: shortTime(json['end_time']),
      room: safeText(json['room']),
      lecturer: safeText(json['lecturer']),
      semester: safeText(json['semester']),
    );
  }
}

// ============================================================
// MODEL CATATAN
// ============================================================

class CourseNoteData {
  final int id;
  final String title;
  final String content;
  final String createdAt;

  const CourseNoteData({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory CourseNoteData.fromJson(Map<String, dynamic> json) {
    return CourseNoteData(
      id: safeInt(json['id']),
      title: safeText(json['title']),
      content: safeText(json['content']),
      createdAt: safeText(json['created_at'], fallback: ''),
    );
  }
}

// ============================================================
// LAYANAN API LARAVEL
// ============================================================

class CourseApiService {
  static Future<Map<String, dynamic>> request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final uri = Uri.parse('$apiBaseUrl$endpoint');

      final request = await client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 10));

      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
      );

      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }

      final response = await request
          .close()
          .timeout(const Duration(seconds: 15));

      final responseText = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 15));

      final decoded = jsonDecode(responseText);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Format respons dari Laravel tidak sesuai.',
        );
      }

      final result = decoded;

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          result['success'] != true) {
        String message = safeText(
          result['message'],
          fallback: 'Permintaan ke server gagal.',
        );

        if (response.statusCode == 422) {
          message = 'Data tidak valid. Periksa kembali isian.';
        }

        throw Exception(message);
      }

      return result;
    } on SocketException {
      throw Exception(
        'Tidak dapat menghubungi Laravel. '
        'Periksa server port 8888 dan ADB Reverse.',
      );
    } on TimeoutException {
      throw Exception(
        'Koneksi ke server terlalu lama. Coba kembali.',
      );
    } on FormatException {
      throw Exception(
        'Server tidak mengirimkan JSON yang valid.',
      );
    } on HttpException {
      throw Exception(
        'Koneksi ke server terputus. Silakan coba lagi.',
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<CourseDetailData> getCourse(String code) async {
    final encodedCode = Uri.encodeComponent(code);

    final result = await request(
      'GET',
      '/courses/$encodedCode',
    );

    final data = result['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Detail mata kuliah tidak ditemukan.');
    }

    return CourseDetailData.fromJson(data);
  }

  static Future<List<CourseNoteData>> getNotes(
    String code,
  ) async {
    final encodedCode = Uri.encodeComponent(code);

    final result = await request(
      'GET',
      '/courses/$encodedCode/notes',
    );

    final data = result['data'];

    if (data is! List) {
      throw Exception('Daftar catatan tidak valid.');
    }

    return data.map((item) {
      return CourseNoteData.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  static Future<void> addNote({
    required String courseCode,
    required String title,
    required String content,
  }) async {
    final encodedCode = Uri.encodeComponent(courseCode);

    await request(
      'POST',
      '/courses/$encodedCode/notes',
      body: {
        'title': title.trim(),
        'content': content.trim(),
      },
    );
  }

  static Future<void> deleteNote(int id) async {
    await request(
      'DELETE',
      '/notes/$id',
    );
  }
}

// ============================================================
// HALAMAN DETAIL MATA KULIAH
// ============================================================

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  // Tetap memakai kode mata kuliah dari navigasi HomeScreen.
  final String courseId;

  @override
  State<CourseDetailScreen> createState() {
    return _CourseDetailScreenState();
  }
}

class _CourseDetailScreenState
    extends State<CourseDetailScreen> {
  CourseDetailData? _course;

  List<CourseNoteData> _notes = [];

  bool _isLoading = true;
  bool _isDeleting = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  // ==========================================================
  // AMBIL DATA LARAVEL
  // ==========================================================

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        CourseApiService.getCourse(widget.courseId),
        CourseApiService.getNotes(widget.courseId),
      ]);

      if (!mounted) return;

      setState(() {
        _course = results[0] as CourseDetailData;
        _notes = results[1] as List<CourseNoteData>;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = errorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade700 : AppColors.navy,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ==========================================================
  // TAMBAH CATATAN
  // ==========================================================

  Future<void> _openAddNote() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AddCourseNoteSheet(
          courseCode: widget.courseId,
        );
      },
    );

    if (!mounted) return;

    if (saved == true) {
      _showMessage('Catatan berhasil disimpan.');

      await _loadData();
    }
  }

  // ==========================================================
  // HAPUS CATATAN
  // ==========================================================

  Future<void> _deleteNote(CourseNoteData note) async {
    if (_isDeleting) return;

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Hapus Catatan?',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            'catatan "${note.title}"?\n\n'
            'Catatan yang dihapus tidak dapat dikembalikan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Ya, Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmation != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await CourseApiService.deleteNote(note.id);

      if (!mounted) return;

      // Hapus dari tampilan setelah API berhasil.
      setState(() {
        _notes.removeWhere((item) => item.id == note.id);
      });

      _showMessage('Catatan berhasil dihapus.');
    } catch (error) {
      _showMessage(
        errorMessage(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // ==========================================================
  // TAMPILAN UTAMA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Mata Kuliah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  // ==========================================================
  // LOADING
  // ==========================================================

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.blue,
          ),
          SizedBox(height: 16),
          Text(
            'Memuat detail mata kuliah...',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 170,
              child: FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ISI HALAMAN
  // ==========================================================

  Widget _buildContent() {
    final course = _course;

    if (course == null) {
      return _buildError();
    }

    return RefreshIndicator(
      color: AppColors.blue,
      onRefresh: _loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          30,
        ),
        children: [
          _buildCourseHeader(course),

          const SizedBox(height: 16),

          _buildCourseInformation(course),

          const SizedBox(height: 24),

          _buildNotesTitle(),

          const SizedBox(height: 14),

          if (_notes.isEmpty)
            _buildEmptyNotes()
          else
            ..._notes.map(_buildNoteCard),

          const SizedBox(height: 22),

          // Lebar tombol mengikuti area ListView.
          // Tidak menggunakan lebar tak terbatas.
          Align(
            alignment: Alignment.center,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Kembali'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(
                  color: AppColors.border,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER NAVY
  // ==========================================================

  Widget _buildCourseHeader(CourseDetailData course) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.yellow,
              size: 28,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            course.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Kelas ${course.className} • ${course.semester}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                Icons.tag_rounded,
                course.code,
              ),
              _buildBadge(
                Icons.school_outlined,
                '${course.credits} SKS',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.navy,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // INFORMASI MATA KULIAH
  // ==========================================================

  Widget _buildCourseInformation(CourseDetailData course) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.blue,
                size: 22,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Informasi Perkuliahan',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Hari',
            value: dayName(course.dayOfWeek),
          ),

          _buildDivider(),

          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Waktu',
            value:
                '${course.startTime} – ${course.endTime} WITA',
          ),

          _buildDivider(),

          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Ruangan',
            value: course.room,
          ),

          _buildDivider(),

          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Dosen Pengampu',
            value: course.lecturer,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: AppColors.blue,
              size: 19,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        color: AppColors.border,
      ),
    );
  }

  // ==========================================================
  // JUDUL BAGIAN CATATAN
  // ==========================================================

  Widget _buildNotesTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              color: AppColors.blue,
              size: 23,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Catatan Mata Kuliah',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        const Text(
          'Simpan dan kelola materi penting perkuliahan.',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 14),

        // PERBAIKAN PENTING:
        // Tombol tidak lagi diletakkan dalam Row
        // yang berpotensi menerima batas lebar tidak sesuai.
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _openAddNote,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Catatan'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // KONDISI BELUM ADA CATATAN
  // ==========================================================

  Widget _buildEmptyNotes() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 22,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.note_add_outlined,
                color: AppColors.blue,
                size: 38,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Belum Ada Catatan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Kamu belum menyimpan catatan untuk '
              'mata kuliah ini.\n'
              'Tekan Tambah Catatan untuk memulai.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // KARTU CATATAN
  // ==========================================================

  Widget _buildNoteCard(CourseNoteData note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.blue,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  tooltip: 'Hapus catatan',
                  onPressed: _isDeleting
                      ? null
                      : () => _deleteNote(note),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SelectableText(
              note.content,
              style: const TextStyle(
                color: AppColors.text,
                height: 1.6,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 16),

            const Divider(
              height: 1,
              color: AppColors.border,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  size: 15,
                  color: AppColors.muted,
                ),

                const SizedBox(width: 6),

                Text(
                  formatDate(note.createdAt),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CARD UMUM
  // ==========================================================

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================
// FORM TAMBAH CATATAN
// ============================================================

class AddCourseNoteSheet extends StatefulWidget {
  const AddCourseNoteSheet({
    super.key,
    required this.courseCode,
  });

  final String courseCode;

  @override
  State<AddCourseNoteSheet> createState() {
    return _AddCourseNoteSheetState();
  }
}

class _AddCourseNoteSheetState
    extends State<AddCourseNoteSheet> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _contentController =
      TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();

    super.dispose();
  }

  // ==========================================================
  // VALIDASI JUDUL
  // ==========================================================

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Judul catatan wajib diisi.';
    }

    if (text.length > 150) {
      return 'Judul maksimal 150 karakter.';
    }

    return null;
  }

  // ==========================================================
  // VALIDASI ISI
  // ==========================================================

  String? _validateContent(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Isi catatan wajib diisi.';
    }

    return null;
  }

  // ==========================================================
  // SIMPAN KE MYSQL MELALUI LARAVEL
  // ==========================================================

  Future<void> _saveNote() async {
    if (_isSaving) return;

    // Jika judul atau isi kosong, proses berhenti di sini.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await CourseApiService.addNote(
        courseCode: widget.courseCode,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage(error)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ==========================================================
  // TAMPILAN FORM
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final keyboardHeight = media.viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: media.size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: keyboardHeight == 0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              autovalidateMode:
                  AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Row(
                    children: [
                      Icon(
                        Icons.note_add_outlined,
                        color: AppColors.blue,
                        size: 28,
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Tambah Catatan',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Tuliskan materi atau poin penting '
                    'dari perkuliahanmu.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    '* Wajib diisi',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ============================================
                  // INPUT JUDUL
                  // ============================================

                  TextFormField(
                    controller: _titleController,
                    enabled: !_isSaving,
                    maxLength: 150,
                    textCapitalization:
                        TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Judul Catatan *',
                      hintText: 'Contoh: Materi Pertemuan 1',
                      prefixIcon: const Icon(
                        Icons.title_rounded,
                        color: AppColors.blue,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.blue,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: _validateTitle,
                  ),

                  const SizedBox(height: 12),

                  // ============================================
                  // INPUT ISI
                  // ============================================

                  TextFormField(
                    controller: _contentController,
                    enabled: !_isSaving,
                    minLines: 4,
                    maxLines: 7,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Isi Catatan *',
                      hintText:
                          'Tuliskan isi catatan perkuliahan...',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.blue,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: _validateContent,
                  ),

                  const SizedBox(height: 24),

                  // ============================================
                  // TOMBOL SIMPAN
                  // ============================================

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _isSaving ? null : _saveNote,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.save_outlined,
                            ),
                      label: Text(
                        _isSaving
                            ? 'Menyimpan...'
                            : 'Simpan Catatan',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ============================================
                  // TOMBOL BATAL
                  // ============================================

                  Center(
                    child: TextButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              Navigator.pop(context, false);
                            },
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}