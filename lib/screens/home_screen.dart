import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../app/theme.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/lifecycle_badge.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/um_widgets.dart';

import 'study_log_screen.dart';
import 'catatan_lokal_screen.dart';

// ============================================================
// KONFIGURASI API LARAVEL
// ============================================================

const String apiBaseUrl = 'http://127.0.0.1:8888/api';

// ============================================================
// MODEL MATA KULIAH
// ============================================================

class TodayCourse {
  final String kode;
  final String nama;
  final int sks;
  final String ruangan;
  final String dosen;
  final String jamMulai;
  final String jamSelesai;

  const TodayCourse({
    required this.kode,
    required this.nama,
    required this.sks,
    required this.ruangan,
    required this.dosen,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory TodayCourse.fromJson(Map<String, dynamic> json) {
    String formatJam(dynamic value) {
      final text = value?.toString() ?? '';

      if (text.length >= 5) {
        return text.substring(0, 5);
      }

      return text;
    }

    return TodayCourse(
      kode: json['course_code']?.toString() ?? '',
      nama: json['course_name']?.toString() ?? '-',
      sks: int.tryParse(json['credits']?.toString() ?? '') ?? 0,
      ruangan: json['room']?.toString() ?? '-',
      dosen: json['lecturer']?.toString() ?? '-',
      jamMulai: formatJam(json['start_time']),
      jamSelesai: formatJam(json['end_time']),
    );
  }
}

// ============================================================
// MODEL JADWAL HARI INI
// ============================================================

class TodaySchedule {
  final String tanggal;
  final int hari;
  final String jamServerWita;
  final List<TodayCourse> courses;

  const TodaySchedule({
    required this.tanggal,
    required this.hari,
    required this.jamServerWita,
    required this.courses,
  });
}

// ============================================================
// HALAMAN BERANDA
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<TodaySchedule> _jadwalFuture;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _jadwalFuture = _ambilJadwalHariIni();

    // Refresh otomatis setiap satu menit.
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _refreshJadwal();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ==========================================================
  // MEMPERBARUI JADWAL
  // ==========================================================

  Future<void> _refreshJadwal() async {
    if (!mounted) return;

    final future = _ambilJadwalHariIni();

    setState(() {
      _jadwalFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  // ==========================================================
  // MENGAMBIL JADWAL DARI API LARAVEL
  // ==========================================================

  Future<TodaySchedule> _ambilJadwalHariIni() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final uri = Uri.parse('$apiBaseUrl/courses/today');

      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 10));

      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );

      final responseBody = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Server mengembalikan HTTP ${response.statusCode}.');
      }

      final decoded = jsonDecode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format respons server tidak sesuai.');
      }

      if (decoded['success'] != true) {
        throw Exception('API gagal mengambil jadwal kuliah.');
      }

      final rawCourses = decoded['data'];

      if (rawCourses is! List) {
        throw const FormatException('Daftar mata kuliah tidak valid.');
      }

      final courses = rawCourses.map((item) {
        return TodayCourse.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();

      // Contoh server_time:
      // 2026-10-27T15:54:01+08:00
      //
      // Kita mengambil jam langsung dari string server WITA.
      // Ini menghindari pergeseran zona waktu emulator.
      final serverTime = decoded['server_time']?.toString() ?? '';

      String jamServerWita = '';

      if (serverTime.length >= 16) {
        jamServerWita = serverTime.substring(11, 16);
      }

      return TodaySchedule(
        tanggal: decoded['date']?.toString() ?? '',
        hari: int.tryParse(decoded['day_of_week']?.toString() ?? '') ?? 0,
        jamServerWita: jamServerWita,
        courses: courses,
      );
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke Laravel. '
        'Periksa server port 8888 dan ADB Reverse.',
      );
    } on TimeoutException {
      throw Exception('Koneksi ke Laravel terlalu lama.');
    } on FormatException {
      throw Exception('Data yang diterima dari server tidak valid.');
    } finally {
      client.close(force: true);
    }
  }

  // ==========================================================
  // FORMAT HARI INDONESIA
  // ==========================================================

  String _namaHari(int hari) {
    const daftarHari = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    if (hari < 1 || hari > 7) {
      return 'Hari ini';
    }

    return daftarHari[hari];
  }

  // ==========================================================
  // FORMAT TANGGAL INDONESIA
  // ==========================================================

  String _tanggalIndonesia(String input) {
    final tanggal = DateTime.tryParse(input);

    if (tanggal == null) {
      return input;
    }

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

  // ==========================================================
  // NAVIGASI STUDYLOG
  // ==========================================================

  void _bukaStudyLog() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const StudyLogScreen()),
    );
  }

  // ==========================================================
  // NAVIGASI CATATAN LOKAL SQLITE
  // ==========================================================

  void _bukaCatatanLokal() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const CatatanLokalScreen()),
    );
  }

  // ==========================================================
  // MEMBANGUN TAMPILAN BERANDA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final student = vm.student;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: umAppBar('Beranda'),

      body: RefreshIndicator(
        color: UmColors.blue,
        onRefresh: _refreshJadwal,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          children: [
            // ================================================
            // PROFIL MAHASISWA
            // ================================================

            _HeroCard(
              nama: student.nama,
              prodi: student.programStudi,
              semester: student.semester,
            ),

            const SizedBox(height: 16),

            // ================================================
            // TOMBOL PROFIL DAN KONTAK
            // ================================================
            Row(
              children: [
                Expanded(
                  child: _MenuButton(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _MenuButton(
                    icon: Icons.contact_mail_outlined,
                    label: 'Kontak',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.contact);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================================================
            // JADWAL KULIAH HARI INI
            // ================================================
            const Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: UmColors.blue,
                  size: 23,
                ),

                SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Jadwal Kuliah Hari Ini',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: UmColors.navy,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            FutureBuilder<TodaySchedule>(
              future: _jadwalFuture,
              builder: (context, snapshot) {
                // ============================================
                // LOADING
                // ============================================

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SectionCard(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(color: UmColors.blue),
                      ),
                    ),
                  );
                }

                // ============================================
                // ERROR
                // ============================================

                if (snapshot.hasError) {
                  return SectionCard(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.red,
                          size: 40,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Gagal Memuat Jadwal',
                          style: TextStyle(
                            color: UmColors.navy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 15),

                        FilledButton.icon(
                          onPressed: _refreshJadwal,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                // ============================================
                // DATA JADWAL
                // ============================================

                final jadwal = snapshot.data;

                if (jadwal == null) {
                  return const SectionCard(
                    child: Text('Data jadwal belum tersedia.'),
                  );
                }

                final courses = jadwal.courses;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_namaHari(jadwal.hari)}, '
                      '${_tanggalIndonesia(jadwal.tanggal)}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${courses.length} mata kuliah hari ini'
                      ' · Waktu Indonesia Tengah (WITA)',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (courses.isEmpty)
                      const SectionCard(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_available_outlined,
                                color: UmColors.blue,
                                size: 42,
                              ),

                              SizedBox(height: 12),

                              Text(
                                'Tidak ada jadwal kuliah hari ini.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      for (final course in courses)
                        _TodayCourseTile(
                          course: course,
                          jamServerWita: jadwal.jamServerWita,
                        ),
                  ],
                );
              },
            ),

            const SizedBox(height: 23),

            // ================================================
            // KARTU CATATAN PERKULIAHAN SQLITE
            // ================================================
            _HomeFeatureCard(
              icon: Icons.menu_book_rounded,
              title: 'Catatan Perkuliahan',
              subtitle: 'Penyimpanan Lokal SQLite',
              description:
                  'Simpan, lihat, edit, dan hapus '
                  'catatan materi kuliah. '
                  'Data dapat diakses tanpa internet.',
              buttonLabel: 'Buka Catatan Lokal',
              badge: 'OFFLINE',
              badgeColor: const Color(0xFFE5F6EF),
              badgeTextColor: const Color(0xFF12815B),
              buttonColor: UmColors.navy,
              onTap: _bukaCatatanLokal,
              features: const [
                _FeatureInfo(icon: Icons.add_circle_outline, label: 'Tambah'),
                _FeatureInfo(icon: Icons.edit_outlined, label: 'Edit'),
                _FeatureInfo(icon: Icons.storage_outlined, label: 'SQLite'),
              ],
            ),

            const SizedBox(height: 16),

            // ================================================
            // KARTU AKTIVITAS BELAJAR STUDYLOG
            // ================================================
            _HomeFeatureCard(
              icon: Icons.auto_stories_rounded,
              title: 'StudyLog',
              subtitle: 'Aktivitas & Riwayat Belajar',
              description:
                  'Pantau perkembangan belajarmu '
                  'dengan mencatat setiap aktivitas '
                  'dan durasi belajar secara teratur.',
              buttonLabel: 'Buka StudyLog',
              badge: 'ONLINE',
              badgeColor: UmColors.yellow,
              badgeTextColor: UmColors.navy,
              buttonColor: UmColors.blue,
              onTap: _bukaStudyLog,
              features: const [
                _FeatureInfo(icon: Icons.timer_outlined, label: 'Durasi'),
                _FeatureInfo(icon: Icons.history_rounded, label: 'Riwayat'),
                _FeatureInfo(icon: Icons.bar_chart_rounded, label: 'Statistik'),
              ],
            ),

            const SizedBox(height: 20),

            // ================================================
            // PEMANTAU LIFECYCLE
            // ================================================
            const LifecycleBadge(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// KARTU JADWAL KULIAH
// ============================================================

class _TodayCourseTile extends StatelessWidget {
  const _TodayCourseTile({required this.course, required this.jamServerWita});

  final TodayCourse course;
  final String jamServerWita;

  int? _ubahJamKeMenit(String jam) {
    final bagian = jam.split(':');

    if (bagian.length != 2) {
      return null;
    }

    final jamAngka = int.tryParse(bagian[0]);
    final menitAngka = int.tryParse(bagian[1]);

    if (jamAngka == null || menitAngka == null) {
      return null;
    }

    if (jamAngka < 0 || jamAngka > 23 || menitAngka < 0 || menitAngka > 59) {
      return null;
    }

    return jamAngka * 60 + menitAngka;
  }

  bool get sedangBerlangsung {
    final sekarang = _ubahJamKeMenit(jamServerWita);
    final mulai = _ubahJamKeMenit(course.jamMulai);
    final selesai = _ubahJamKeMenit(course.jamSelesai);

    if (sekarang == null || mulai == null || selesai == null) {
      return false;
    }

    return sekarang >= mulai && sekarang < selesai;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),

      child: SectionCard(
        padding: EdgeInsets.zero,

        child: ListTile(
          contentPadding: const EdgeInsets.all(13),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          leading: const CircleAvatar(
            backgroundColor: UmColors.blue,
            child: Icon(Icons.menu_book_outlined, color: Colors.white),
          ),

          title: Text(
            course.nama,
            style: const TextStyle(
              color: UmColors.navy,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),

              Text('${course.kode} · ${course.sks} SKS'),

              const SizedBox(height: 4),

              Text(
                '${course.jamMulai}–'
                '${course.jamSelesai} WITA',
              ),

              const SizedBox(height: 3),

              Text('Ruangan: ${course.ruangan}'),

              const SizedBox(height: 3),

              Text(course.dosen, style: const TextStyle(fontSize: 11)),

              if (sedangBerlangsung)
                const Padding(
                  padding: EdgeInsets.only(top: 7),
                  child: Text(
                    '● Sedang berlangsung',
                    style: TextStyle(
                      color: Color(0xFF158458),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: UmColors.navy,
          ),

          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.courseDetail,
              arguments: course.kode,
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// MODEL INFORMASI FITUR
// ============================================================

class _FeatureInfo {
  final IconData icon;
  final String label;

  const _FeatureInfo({required this.icon, required this.label});
}

// ============================================================
// KARTU FITUR BERANDA
// ============================================================

class _HomeFeatureCard extends StatelessWidget {
  const _HomeFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buttonLabel,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.buttonColor,
    required this.onTap,
    required this.features,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String buttonLabel;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color buttonColor;
  final VoidCallback onTap;
  final List<_FeatureInfo> features;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: const Color(0xFFE4EAF3)),

        boxShadow: [
          BoxShadow(
            color: UmColors.navy.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================================
            // BAGIAN JUDUL
            // ================================================

            Row(
              children: [
                Container(
                  width: 47,
                  height: 47,

                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(13),
                  ),

                  child: Icon(icon, color: UmColors.blue, size: 27),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: UmColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 5),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            // ================================================
            // DESKRIPSI
            // ================================================
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF657287),
                fontSize: 13,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 17),

            // ================================================
            // LABEL FITUR
            // ================================================
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features.map((feature) {
                return _FeatureChip(icon: feature.icon, label: feature.label);
              }).toList(),
            ),

            const SizedBox(height: 19),

            // ================================================
            // TOMBOL BUKA HALAMAN
            // ================================================
            SizedBox(
              width: double.infinity,

              child: FilledButton.icon(
                onPressed: onTap,

                icon: const Icon(Icons.arrow_forward_rounded, size: 19),

                label: Text(buttonLabel),

                style: FilledButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(vertical: 15),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),

                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CHIP INFORMASI FITUR
// ============================================================

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: const Color(0xFFE4EAF3)),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 15, color: UmColors.blue),

          const SizedBox(width: 6),

          Text(
            label,
            style: const TextStyle(
              color: UmColors.navy,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// KARTU PROFIL MAHASISWA
// ============================================================

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.nama,
    required this.prodi,
    required this.semester,
  });

  final String nama;
  final String prodi;
  final int semester;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: UmColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),

            decoration: const BoxDecoration(
              color: UmColors.yellow,
              shape: BoxShape.circle,
            ),

            child: const ProfileAvatar(radius: 36),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat datang,',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 4),

                Text(
                  nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  prodi,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: UmColors.yellow,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    'Semester $semester',
                    style: const TextStyle(
                      color: UmColors.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TOMBOL PROFIL DAN KONTAK
// ============================================================

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
