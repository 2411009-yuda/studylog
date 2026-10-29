import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

// ============================================================
// STUDYLOG - RIWAYAT AKTIVITAS BELAJAR
// Laravel REST API + MySQL
// ============================================================

const String _apiBaseUrl = 'http://127.0.0.1:8888/api';

class _StudyColors {
  static const navy = Color(0xFF071F57);
  static const blue = Color(0xFF1664D9);
  static const yellow = Color(0xFFFFCB32);
  static const background = Color(0xFFF4F7FC);
  static const border = Color(0xFFE4EAF3);
  static const muted = Color(0xFF748096);
  static const text = Color(0xFF243047);
  static const green = Color(0xFF16996C);
}

String _text(dynamic value, [String fallback = '-']) {
  if (value == null) return fallback;

  final result = value.toString().trim();

  return result.isEmpty ? fallback : result;
}

int _number(dynamic value) {
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _dateForApi(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

String _dateForDisplay(String value) {
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

String _durationText(int minutes) {
  if (minutes < 60) return '$minutes menit';

  final hours = minutes ~/ 60;
  final remainder = minutes % 60;

  if (remainder == 0) {
    return '$hours jam';
  }

  return '$hours jam $remainder menit';
}

String _errorText(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}

// ============================================================
// MODEL MATA KULIAH
// ============================================================

class _StudyCourse {
  final int id;
  final String name;
  final String code;

  const _StudyCourse({
    required this.id,
    required this.name,
    required this.code,
  });

  factory _StudyCourse.fromJson(Map<String, dynamic> json) {
    return _StudyCourse(
      id: _number(json['id']),
      name: _text(json['course_name']),
      code: _text(json['course_code']),
    );
  }
}

// ============================================================
// MODEL AKTIVITAS BELAJAR
// ============================================================

class _StudyActivity {
  final int id;
  final int courseId;
  final String courseName;
  final String studiedOn;
  final int durationMinutes;
  final String topic;
  final String notes;

  const _StudyActivity({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.studiedOn,
    required this.durationMinutes,
    required this.topic,
    required this.notes,
  });

  factory _StudyActivity.fromJson(Map<String, dynamic> json) {
    return _StudyActivity(
      id: _number(json['id']),
      courseId: _number(json['course_id']),
      courseName: _text(json['course_name']),
      studiedOn: _text(json['studied_on']),
      durationMinutes: _number(json['duration_minutes']),
      topic: _text(json['topic']),
      notes: _text(json['notes'], ''),
    );
  }
}

// ============================================================
// MODEL STATISTIK
// ============================================================

class _StudyStats {
  final int totalSessions;
  final int totalMinutes;
  final int totalCourses;
  final int weeklySessions;
  final int weeklyMinutes;

  const _StudyStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.totalCourses,
    required this.weeklySessions,
    required this.weeklyMinutes,
  });

  factory _StudyStats.fromJson(Map<String, dynamic> json) {
    return _StudyStats(
      totalSessions: _number(json['total_sessions']),
      totalMinutes: _number(json['total_minutes']),
      totalCourses: _number(json['total_courses']),
      weeklySessions: _number(json['weekly_sessions']),
      weeklyMinutes: _number(json['weekly_minutes']),
    );
  }

  static const empty = _StudyStats(
    totalSessions: 0,
    totalMinutes: 0,
    totalCourses: 0,
    weeklySessions: 0,
    weeklyMinutes: 0,
  );
}

// ============================================================
// API SERVICE
// ============================================================

class _StudyApi {
  static Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final uri = Uri.parse('$_apiBaseUrl$path');

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
        throw Exception('Format data server tidak sesuai.');
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] != true) {
        throw Exception(
          _text(
            decoded['message'],
            'Permintaan ke server gagal.',
          ),
        );
      }

      return decoded;
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke Laravel. '
        'Pastikan server port 8888 dan ADB Reverse aktif.',
      );
    } on TimeoutException {
      throw Exception(
        'Koneksi terlalu lama. Coba lagi.',
      );
    } on FormatException {
      throw Exception(
        'Respons server bukan JSON yang valid.',
      );
    } on HttpException {
      throw Exception(
        'Koneksi server terputus. Coba lagi.',
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<List<_StudyCourse>> getCourses() async {
    final result = await request('GET', '/courses');

    final data = result['data'];

    if (data is! List) {
      throw Exception('Daftar mata kuliah tidak valid.');
    }

    return data.map((item) {
      return _StudyCourse.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  static Future<List<_StudyActivity>> getActivities() async {
    final result = await request('GET', '/study-logs');

    final data = result['data'];

    if (data is! List) {
      throw Exception('Riwayat belajar tidak valid.');
    }

    return data.map((item) {
      return _StudyActivity.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  static Future<_StudyStats> getStats() async {
    final result = await request(
      'GET',
      '/study-logs/stats',
    );

    final data = result['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Statistik belajar tidak valid.');
    }

    return _StudyStats.fromJson(data);
  }

  static Future<void> addActivity({
    required int courseId,
    required String studiedOn,
    required int durationMinutes,
    required String topic,
    required String notes,
  }) async {
    await request(
      'POST',
      '/study-logs',
      body: {
        'course_id': courseId,
        'studied_on': studiedOn,
        'duration_minutes': durationMinutes,
        'topic': topic.trim(),
        'notes': notes.trim().isEmpty ? null : notes.trim(),
      },
    );
  }

  static Future<void> deleteActivity(int id) async {
    await request(
      'DELETE',
      '/study-logs/$id',
    );
  }
}

// ============================================================
// HALAMAN UTAMA STUDYLOG
// ============================================================

class StudyLogScreen extends StatefulWidget {
  const StudyLogScreen({super.key});

  @override
  State<StudyLogScreen> createState() {
    return _StudyLogScreenState();
  }
}

class _StudyLogScreenState extends State<StudyLogScreen> {
  List<_StudyActivity> _activities = [];
  List<_StudyCourse> _courses = [];

  _StudyStats _stats = _StudyStats.empty;

  bool _loading = true;
  bool _deleting = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _StudyApi.getActivities(),
        _StudyApi.getStats(),
        _StudyApi.getCourses(),
      ]);

      if (!mounted) return;

      setState(() {
        _activities = results[0] as List<_StudyActivity>;
        _stats = results[1] as _StudyStats;
        _courses = results[2] as List<_StudyCourse>;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = _errorText(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error
              ? Colors.red.shade700
              : _StudyColors.navy,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _openAddActivity() async {
    if (_courses.isEmpty) {
      _showMessage(
        'Daftar mata kuliah belum tersedia.',
        error: true,
      );
      return;
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddStudyActivitySheet(
          courses: _courses,
        );
      },
    );

    if (!mounted) return;

    if (saved == true) {
      _showMessage('Aktivitas belajar berhasil disimpan.');
      await _loadData();
    }
  }

  Future<void> _deleteActivity(_StudyActivity activity) async {
    if (_deleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Hapus Aktivitas?',
            style: TextStyle(
              color: _StudyColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Aktivitas belajar "${activity.topic}" '
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

    if (confirmed != true || !mounted) return;

    setState(() {
      _deleting = true;
    });

    try {
      await _StudyApi.deleteActivity(activity.id);

      if (!mounted) return;

      _showMessage('Aktivitas berhasil dihapus.');
      await _loadData();
    } catch (error) {
      _showMessage(
        _errorText(error),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _StudyColors.background,
      appBar: AppBar(
        backgroundColor: _StudyColors.navy,
        foregroundColor: Colors.white,
        title: const Text(
          'StudyLog',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loading ? null : _loadData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _buildContent(),
      floatingActionButton: _loading || _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddActivity,
              backgroundColor: _StudyColors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Aktivitas'),
            ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: _StudyColors.blue,
          ),
          SizedBox(height: 15),
          Text(
            'Memuat aktivitas belajar...',
            style: TextStyle(
              color: _StudyColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 54,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            const Text(
              'Gagal Memuat StudyLog',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: _StudyColors.navy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _StudyColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: _StudyColors.blue,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          110,
        ),
        children: [
          _buildHero(),

          const SizedBox(height: 18),

          _buildStats(),

          const SizedBox(height: 25),

          const Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: _StudyColors.blue,
                size: 24,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Riwayat Aktivitas Belajar',
                  style: TextStyle(
                    color: _StudyColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            '${_activities.length} aktivitas tersimpan',
            style: const TextStyle(
              color: _StudyColors.muted,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          if (_activities.isEmpty)
            _buildEmptyState()
          else
            ..._activities.map(_buildActivityCard),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _StudyColors.navy,
        borderRadius: BorderRadius.circular(22),
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
              Icons.auto_stories_rounded,
              color: _StudyColors.yellow,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Perjalanan Belajarmu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Catat setiap sesi belajar dan pantau '
            'perkembanganmu dari waktu ke waktu.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Total Belajar',
                value: _durationText(_stats.totalMinutes),
                icon: Icons.timer_outlined,
                color: _StudyColors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'Total Sesi',
                value: '${_stats.totalSessions}',
                icon: Icons.check_circle_outline_rounded,
                color: _StudyColors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Minggu Ini',
                value: _durationText(_stats.weeklyMinutes),
                icon: Icons.calendar_month_outlined,
                color: const Color(0xFF9B61C9),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'Mata Kuliah',
                value: '${_stats.totalCourses}',
                icon: Icons.school_outlined,
                color: const Color(0xFFD28A18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: _StudyColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 25,
          ),
          const SizedBox(height: 13),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _StudyColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: _StudyColors.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _StudyColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            color: _StudyColors.blue,
            size: 52,
          ),
          SizedBox(height: 14),
          Text(
            'Belum Ada Aktivitas',
            style: TextStyle(
              color: _StudyColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mulai catat kegiatan belajarmu '
            'dengan tombol Tambah Aktivitas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _StudyColors.muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(_StudyActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _StudyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _StudyColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  color: _StudyColors.blue,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.courseName,
                      style: const TextStyle(
                        color: _StudyColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _dateForDisplay(activity.studiedOn),
                      style: const TextStyle(
                        color: _StudyColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: 'Hapus aktivitas',
                onPressed: _deleting
                    ? null
                    : () => _deleteActivity(activity),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            activity.topic,
            style: const TextStyle(
              color: _StudyColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),

          if (activity.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              activity.notes,
              style: const TextStyle(
                color: _StudyColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 15),

          const Divider(
            color: _StudyColors.border,
            height: 1,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 17,
                color: _StudyColors.blue,
              ),
              const SizedBox(width: 6),
              Text(
                _durationText(activity.durationMinutes),
                style: const TextStyle(
                  color: _StudyColors.navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FORM TAMBAH AKTIVITAS BELAJAR
// ============================================================

class _AddStudyActivitySheet extends StatefulWidget {
  const _AddStudyActivitySheet({
    required this.courses,
  });

  final List<_StudyCourse> courses;

  @override
  State<_AddStudyActivitySheet> createState() {
    return _AddStudyActivitySheetState();
  }
}

class _AddStudyActivitySheetState
    extends State<_AddStudyActivitySheet> {
  final _formKey = GlobalKey<FormState>();

  final _durationController = TextEditingController();
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedCourseId;

  DateTime _selectedDate = DateTime.now();

  bool _saving = false;

  @override
  void dispose() {
    _durationController.dispose();
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (_saving) return;

    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Pilih Tanggal Belajar',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  String? _validateCourse(int? value) {
    if (value == null) {
      return 'Mata kuliah wajib dipilih.';
    }

    return null;
  }

  String? _validateDuration(String? value) {
    final input = value?.trim() ?? '';

    if (input.isEmpty) {
      return 'Durasi belajar wajib diisi.';
    }

    final minutes = int.tryParse(input);

    if (minutes == null) {
      return 'Durasi harus berupa angka.';
    }

    if (minutes < 1) {
      return 'Durasi minimal 1 menit.';
    }

    if (minutes > 1440) {
      return 'Durasi maksimal 1440 menit.';
    }

    return null;
  }

  String? _validateTopic(String? value) {
    final topic = value?.trim() ?? '';

    if (topic.isEmpty) {
      return 'Materi yang dipelajari wajib diisi.';
    }

    if (topic.length > 200) {
      return 'Materi maksimal 200 karakter.';
    }

    return null;
  }

  Future<void> _save() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _StudyApi.addActivity(
        courseId: _selectedCourseId!,
        studiedOn: _dateForApi(_selectedDate),
        durationMinutes: int.parse(
          _durationController.text.trim(),
        ),
        topic: _topicController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(_errorText(error)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(
        bottom: media.viewInsets.bottom,
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
          bottom: media.viewInsets.bottom == 0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              26,
            ),
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
                        color: _StudyColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Tambah Aktivitas Belajar',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: _StudyColors.navy,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Catat kegiatan belajarmu secara teratur.',
                    style: TextStyle(
                      color: _StudyColors.muted,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    '* Wajib diisi',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 23),

                  // ==========================================
                  // PILIH MATA KULIAH
                  // ==========================================

                  DropdownButtonFormField<int>(
                    initialValue: _selectedCourseId,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      'Mata Kuliah *',
                      Icons.school_outlined,
                    ),
                    hint: const Text(
                      'Pilih mata kuliah',
                      overflow: TextOverflow.ellipsis,
                    ),
                    items: widget.courses.map((course) {
                      return DropdownMenuItem<int>(
                        value: course.id,
                        child: Text(
                          course.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedCourseId = value;
                            });
                          },
                    validator: _validateCourse,
                  ),

                  const SizedBox(height: 15),

                  // ==========================================
                  // PILIH TANGGAL
                  // ==========================================

                  const Text(
                    'Tanggal Belajar *',
                    style: TextStyle(
                      color: _StudyColors.navy,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _pickDate,
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                      ),
                      label: Text(
                        _dateForDisplay(
                          _dateForApi(_selectedDate),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _StudyColors.navy,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 16,
                        ),
                        side: const BorderSide(
                          color: _StudyColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==========================================
                  // INPUT DURASI
                  // ==========================================

                  TextFormField(
                    controller: _durationController,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      'Durasi Belajar (menit) *',
                      Icons.timer_outlined,
                    ).copyWith(
                      hintText: 'Contoh: 90',
                      helperText:
                          'Minimal 1 menit, maksimal 1440 menit.',
                    ),
                    validator: _validateDuration,
                  ),

                  const SizedBox(height: 15),

                  // ==========================================
                  // INPUT MATERI
                  // ==========================================

                  TextFormField(
                    controller: _topicController,
                    enabled: !_saving,
                    maxLength: 200,
                    textCapitalization:
                        TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      'Materi Dipelajari *',
                      Icons.menu_book_outlined,
                    ).copyWith(
                      hintText: 'Contoh: Logika Proposisional',
                    ),
                    validator: _validateTopic,
                  ),

                  const SizedBox(height: 15),

                  // ==========================================
                  // CATATAN OPSIONAL
                  // ==========================================

                  TextFormField(
                    controller: _notesController,
                    enabled: !_saving,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Catatan Aktivitas (Opsional)',
                      hintText:
                          'Contoh: Menyelesaikan 10 soal latihan.',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: _StudyColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _StudyColors.border,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==========================================
                  // TOMBOL SIMPAN
                  // ==========================================

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
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
                        _saving
                            ? 'Menyimpan...'
                            : 'Simpan Aktivitas',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _StudyColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: TextButton(
                      onPressed: _saving
                          ? null
                          : () {
                              Navigator.pop(context, false);
                            },
                      child: const Text('Batal'),
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

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: _StudyColors.blue,
      ),
      filled: true,
      fillColor: _StudyColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _StudyColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _StudyColors.blue,
          width: 1.5,
        ),
      ),
    );
  }
}