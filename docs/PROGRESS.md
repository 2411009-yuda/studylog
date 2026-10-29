# Alur Progres Pengerjaan - Profil Mahasiswa (Materi 5)

Pekerjaan dibagi menjadi 16 tahap kecil. Setiap tahap = satu commit dengan pesan yang menjelaskan perubahannya
(sesuai standar commit di Materi 2: singkat, jelas, berawalan kata kerja, satu commit satu perubahan utama).

## Tahap pengerjaan

| # | Tahap | Hasil | Pesan commit |
|---|---|---|---|
| 1 | Fondasi project | `pubspec.yaml`, `.gitignore`, `main.dart` awal | inisialisasi project flutter profil mahasiswa |
| 2 | Aset | foto profil bawaan (di-crop persegi untuk avatar) | tambah foto profil bawaan sebagai aset |
| 3 | Tema | warna Universitas Mulia, AppBar bergaris merah-kuning, kartu dasar | tambah tema warna Universitas Mulia dan widget dasar |
| 4 | Model | `Student`, `Course` | tambah model data Student dan Course |
| 5 | ViewModel | `ProfileViewModel`: state profil, validasi, daftar mata kuliah | tambah ProfileViewModel dengan validasi input dan data mata kuliah |
| 6 | Route | `AppRoutes` untuk 4 destination | tambah daftar route untuk setiap layar |
| 7 | Layar 1 | Beranda | tambah layar Beranda dengan ringkasan profil dan daftar mata kuliah |
| 8 | Layar 2 | Profil + dialog Edit Profil | tambah layar Profil dengan form edit nama dan program studi |
| 9 | Layar 3 | Detail Mata Kuliah (menerima id lewat route) | tambah layar Detail Mata Kuliah yang menerima id lewat route |
| 10 | Layar tambahan | Kontak: email, portofolio, GitHub | tambah layar Kontak berisi email, web portofolio, dan GitHub |
| 11 | Navigasi | `onGenerateRoute` + Provider di atas `MaterialApp` | hubungkan semua layar dengan Navigator dan Provider ViewModel |
| 12 | Fitur foto | ganti foto dari galeri/kamera | tambah fitur ganti foto profil dari galeri atau kamera |
| 13 | Lifecycle | pemantau lifecycle & orientasi | tambah pemantau lifecycle dan orientasi pada layar Beranda |
| 14 | Pengujian | unit test ViewModel + widget test navigasi | tambah unit test ViewModel dan widget test alur navigasi |
| 15 | Dokumentasi | README dan dokumen ini | lengkapi README dan dokumentasi alur progres |
| 16 | Data kurikulum | 8 mata kuliah semester 5 (23 SKS, tanpa Robotika) dengan kode dan prasyarat | sesuaikan data mata kuliah dengan kurikulum semester 5 |

## Pemetaan ke Checklist Materi 5

| Checklist | Status | Bukti |
|---|---|---|
| Minimal 3 layar | Ada 4 layar | `lib/screens/` |
| Setiap layar punya route jelas | Ya | `lib/app/routes.dart`, `app_router.dart` |
| Navigation tanpa crash | Perlu dijalankan di emulator | skenario uji manual di README |
| Tombol kembali sesuai alur | Perlu dijalankan di emulator | `Navigator.pop` / BackButton, ada widget test |
| ViewModel menyimpan UI State | Ya | `ProfileViewModel` (nama, prodi, foto) |
| Commit GitHub dengan pesan jelas | 16 commit | tabel di atas |
| Layar baru: Kontak | Ya | `contact_screen.dart` |
| Repository GitHub + screenshot hasil run | Langkah di bawah | `docs/screenshots/` |

## Langkah Push ke GitHub

```bash
# 1. buat repository kosong di GitHub, misalnya: profil-mahasiswa-yuda
#    (jangan centang "Add README", karena README sudah ada)

# 2. dari folder project
git remote add origin https://github.com/2411009-yuda/profil-mahasiswa-yuda.git
git push -u origin main
```

Setelah menjalankan `flutter create .` (lihat README), commit folder platform sebagai commit terpisah:

```bash
git add -A
git commit -m "tambah konfigurasi platform android dan ios"
git push
```

## Yang Dikumpulkan

1. Link repository GitHub.
2. Screenshot hasil run (simpan di `docs/screenshots/`): Beranda, Profil, Detail Mata Kuliah, Kontak, dan form Edit Profil dengan pesan error.
3. Ketentuan Materi 5: minimal commit bermakna sudah terpenuhi (16 commit).
