import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profil_mahasiswa/app/app.dart';

// ============================================================
// PENGATURAN LAYAR PENGUJIAN
// ============================================================

void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ============================================================
// PENGUJIAN NAVIGASI APLIKASI
// ============================================================

void main() {
  // ----------------------------------------------------------
  // TEST 1: BERANDA -> PROFIL -> BERANDA
  // ----------------------------------------------------------

  testWidgets('Beranda -> Profil -> kembali mengikuti back stack', (
    tester,
  ) async {
    useTallScreen(tester);

    await tester.pumpWidget(const ProfilMahasiswaApp());

    expect(find.text('Beranda'), findsOneWidget);

    await tester.tap(find.text('Profil'));

    await tester.pumpAndSettle();

    expect(find.text('NIM'), findsOneWidget);

    expect(find.text('2411009'), findsOneWidget);

    await tester.pageBack();

    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
  });

  // ----------------------------------------------------------
  // TEST 2: BERANDA -> PROFIL -> EDIT -> BATAL
  //
  // Menggantikan pengujian lama yang mencari mata kuliah
  // tertentu pada jadwal dinamis Laravel.
  // ----------------------------------------------------------

  testWidgets('Navigasi ke formulir Edit Profil dan membatalkan perubahan', (
    tester,
  ) async {
    useTallScreen(tester);

    await tester.pumpWidget(const ProfilMahasiswaApp());

    // Pastikan halaman utama berhasil ditampilkan.
    expect(find.text('Beranda'), findsOneWidget);

    // Masuk ke halaman Profil.
    await tester.tap(find.text('Profil'));

    await tester.pumpAndSettle();

    // Pastikan tombol Edit Profil tersedia.
    expect(find.text('Edit Profil'), findsOneWidget);

    // Buka formulir edit.
    await tester.tap(find.text('Edit Profil'));

    await tester.pumpAndSettle();

    // Pastikan formulir mempunyai kolom input.
    expect(find.byType(TextFormField), findsWidgets);

    // Batalkan proses edit.
    await tester.tap(find.text('Batal'));

    await tester.pumpAndSettle();

    // Pastikan dialog sudah ditutup.
    expect(find.byType(TextFormField), findsNothing);

    // Pastikan kembali ke halaman Profil.
    expect(find.text('Edit Profil'), findsOneWidget);

    // Kembali ke halaman utama.
    await tester.pageBack();

    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
  });

  // ----------------------------------------------------------
  // TEST 3: BERANDA -> KONTAK
  // ----------------------------------------------------------

  testWidgets('Beranda -> Kontak menampilkan email, web, dan GitHub', (
    tester,
  ) async {
    useTallScreen(tester);

    await tester.pumpWidget(const ProfilMahasiswaApp());

    await tester.tap(find.text('Kontak'));

    await tester.pumpAndSettle();

    expect(
      find.text('2411009@students.universitasmulia.ac.id'),
      findsOneWidget,
    );

    expect(find.text('https://yuda-pratama.web.id/'), findsOneWidget);

    expect(find.text('https://github.com/2411009-yuda'), findsOneWidget);
  });

  // ----------------------------------------------------------
  // TEST 4: STATE VIEWMODEL BERTAHAN SAAT ROTASI
  // ----------------------------------------------------------

  testWidgets('State ViewModel bertahan saat pindah layar dan rotasi', (
    tester,
  ) async {
    useTallScreen(tester);

    await tester.pumpWidget(const ProfilMahasiswaApp());

    // Masuk ke halaman Profil.
    await tester.tap(find.text('Profil'));

    await tester.pumpAndSettle();

    // Buka dialog Edit Profil.
    await tester.tap(find.text('Edit Profil'));

    await tester.pumpAndSettle();

    // Ubah nama mahasiswa.
    await tester.enterText(
      find.byType(TextFormField).first,
      'Yuda Pratama Putra',
    );

    await tester.pump();

    // Simpan perubahan.
    await tester.tap(find.text('Simpan'));

    await tester.pumpAndSettle();

    // Pastikan nama berubah.
    expect(find.text('Yuda Pratama Putra'), findsOneWidget);

    // Simulasikan perubahan orientasi layar.
    tester.view.physicalSize = const Size(900, 400);

    await tester.pumpAndSettle();

    // State harus tetap bertahan.
    expect(find.text('Yuda Pratama Putra'), findsOneWidget);

    // Kembali ke halaman utama.
    await tester.pageBack();

    await tester.pumpAndSettle();

    // Data profil tetap menggunakan nama terbaru.
    expect(find.text('Yuda Pratama Putra'), findsOneWidget);
  });

  // ----------------------------------------------------------
  // TEST 5: VALIDASI INPUT PROFIL
  // ----------------------------------------------------------

  testWidgets('Tombol Simpan nonaktif saat input tidak valid', (tester) async {
    useTallScreen(tester);

    await tester.pumpWidget(const ProfilMahasiswaApp());

    // Masuk ke halaman Profil.
    await tester.tap(find.text('Profil'));

    await tester.pumpAndSettle();

    // Buka formulir Edit Profil.
    await tester.tap(find.text('Edit Profil'));

    await tester.pumpAndSettle();

    // Kosongkan kolom nama.
    await tester.enterText(find.byType(TextFormField).first, '');

    await tester.pump();

    // Pesan validasi harus muncul.
    expect(find.text('Nama wajib diisi'), findsOneWidget);

    // Ambil widget tombol Simpan.
    final simpan = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Simpan'),
    );

    // Tombol harus nonaktif.
    expect(simpan.onPressed, isNull);
  });
}
