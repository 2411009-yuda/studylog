# StudyLog Mahasiswa

**Aplikasi Mobile Flutter untuk Jadwal Perkuliahan, Catatan Offline, dan Aktivitas Belajar**

StudyLog Mahasiswa merupakan aplikasi Android berbasis **Flutter** yang dikembangkan untuk mendukung kegiatan perkuliahan mahasiswa.

Aplikasi ini menggabungkan fitur profil mahasiswa, jadwal perkuliahan otomatis, informasi mata kuliah, catatan perkuliahan, serta pencatatan aktivitas belajar melalui StudyLog.

Project ini merupakan pengembangan dari tugas **Pemrograman Aplikasi Bergerak — Universitas Mulia**, khususnya materi *Navigation, Lifecycle, dan ViewModel*.

---

## 1. Informasi Project

| Informasi | Keterangan |
|---|---|
| Nama aplikasi | StudyLog Mahasiswa |
| Platform utama | Android |
| Framework | Flutter |
| Bahasa pemrograman | Dart |
| State management | Provider / ChangeNotifier |
| Backend | Laravel 12 REST API |
| Database server | MySQL / MariaDB |
| Database lokal | SQLite |
| Arsitektur | Flutter Client + Laravel REST API |
| Zona waktu jadwal | Asia/Makassar (WITA) |
| Status | Prototipe pengembangan |

### Repository GitHub

**Frontend Flutter:**

https://github.com/wisnuwardhana822/flutter-studylog-mahasiswa

**Backend Laravel:**

https://github.com/wisnuwardhana822/laravel-studylog-api

Kedua repository merupakan bagian dari satu sistem aplikasi StudyLog Mahasiswa.

---

## 2. Latar Belakang

Mahasiswa sering membutuhkan beberapa tempat berbeda untuk melihat jadwal kuliah, menyimpan materi, dan mencatat aktivitas belajar.

StudyLog Mahasiswa dikembangkan untuk menggabungkan kebutuhan tersebut dalam satu aplikasi mobile.

Aplikasi ini menggunakan pendekatan penyimpanan data yang berbeda sesuai kebutuhan:

- **Laravel/MySQL** untuk data yang diakses melalui REST API.
- **SQLite** untuk catatan lokal yang dapat diakses tanpa koneksi internet.
- **Provider** untuk pengelolaan state antarmuka, termasuk informasi profil mahasiswa.

Dengan pendekatan ini, aplikasi dapat digunakan sebagai dasar pengembangan sistem pembelajaran mahasiswa yang lebih lengkap.

---

## 3. Fitur Utama

### 3.1 Beranda

Halaman Beranda menampilkan:

- Kartu identitas mahasiswa.
- Navigasi menuju halaman Profil.
- Navigasi menuju halaman Kontak.
- Jadwal perkuliahan hari ini.
- Informasi mata kuliah.
- Akses ke catatan perkuliahan offline.
- Akses ke StudyLog.
- Informasi lifecycle aplikasi.

Jadwal kuliah diambil dari REST API Laravel berdasarkan hari pada zona waktu **Asia/Makassar**.

Pengguna tidak perlu memilih hari secara manual untuk melihat jadwal hari ini.

### 3.2 Jadwal Perkuliahan Otomatis

Fitur jadwal menampilkan mata kuliah berdasarkan hari berjalan.

Informasi yang tersedia meliputi:

- Nama mata kuliah.
- Kode mata kuliah.
- Jumlah SKS.
- Waktu perkuliahan.
- Ruangan.
- Dosen pengampu.

Sumber data jadwal berasal dari database MySQL melalui backend Laravel.

Endpoint utama:

```http
GET /api/courses/today
```

Endpoint untuk seluruh mata kuliah:

```http
GET /api/courses
```

### 3.3 Detail Mata Kuliah

Pengguna dapat memilih mata kuliah dari jadwal untuk membuka halaman detail.

Halaman ini menampilkan informasi perkuliahan dan menyediakan fitur catatan yang terhubung dengan backend.

Fitur catatan online mencakup:

- Menampilkan catatan.
- Menambahkan catatan.
- Menghapus catatan.
- Validasi input.
- Konfirmasi penghapusan.
- Pesan keberhasilan atau kegagalan operasi.

Catatan ini disimpan di **MySQL**, bukan SQLite.

### 3.4 Catatan Perkuliahan Offline

Aplikasi menyediakan fitur catatan lokal menggunakan SQLite.

Fitur yang tersedia:

- Menambahkan catatan baru.
- Melihat daftar catatan.
- Membaca detail catatan.
- Mengubah catatan.
- Menghapus catatan.
- Validasi kolom yang wajib diisi.
- Konfirmasi sebelum menghapus data.
- Menampilkan pesan hasil operasi.

Setiap catatan dapat berisi:

- Nama mata kuliah.
- Judul catatan.
- Isi catatan.
- Informasi tanggal pembuatan.

Catatan disimpan pada perangkat Android.

**Fitur ini dapat digunakan tanpa koneksi internet untuk mengelola data lokal.**

### 3.5 StudyLog

StudyLog digunakan untuk mencatat aktivitas belajar mahasiswa.

Fitur yang tersedia:

- Menambahkan aktivitas belajar.
- Memilih mata kuliah.
- Memilih tanggal belajar.
- Mengisi durasi belajar.
- Mengisi materi yang dipelajari.
- Menambahkan catatan aktivitas.
- Menampilkan riwayat aktivitas belajar.
- Menampilkan statistik belajar.
- Menghapus aktivitas belajar.

Data StudyLog menggunakan backend Laravel dan database MySQL.

Contoh informasi statistik:

- Total sesi belajar.
- Total durasi belajar.
- Durasi belajar minggu ini.
- Jumlah mata kuliah yang pernah dipelajari.

### 3.6 Profil Mahasiswa

Fitur profil merupakan bagian dari tugas awal aplikasi.

Fitur yang tersedia:

- Menampilkan identitas mahasiswa.
- Mengubah nama mahasiswa.
- Mengubah program studi.
- Mengganti foto profil.
- Menggunakan kembali foto bawaan.
- Validasi input.
- Pengelolaan state menggunakan Provider.

### 3.7 Kontak

Halaman Kontak menyediakan informasi seperti:

- Email.
- Website portofolio.
- GitHub.

Aplikasi menggunakan `url_launcher` untuk membuka tautan eksternal yang didukung.

### 3.8 Lifecycle dan Navigasi

Aplikasi mempertahankan fitur pembelajaran Flutter dari tugas awal, termasuk:

- Named routes.
- Navigasi antarlayar.
- Back stack.
- Pengiriman argument antarhalaman.
- ViewModel berbasis ChangeNotifier.
- Pemantauan lifecycle aplikasi.
- Informasi orientasi layar.

---

## 4. Teknologi dan Dependensi

### Teknologi Utama

| Teknologi | Fungsi |
|---|---|
| Flutter | Framework aplikasi mobile |
| Dart | Bahasa pemrograman Flutter |
| Provider | Pengelolaan state |
| SQLite | Penyimpanan catatan lokal |
| Laravel | REST API backend |
| MySQL | Penyimpanan data server |
| Git | Version control |
| GitHub | Kolaborasi dan penyimpanan source code |

### Dependensi Flutter

Dependensi aplikasi yang tercantum pada `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  provider: ^6.1.2
  url_launcher: ^6.3.1
  image_picker: ^1.1.2
  sqflite: ^2.4.5
  path: ^1.9.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^6.0.0
```

Kegunaan dependensi:

- `provider`: mengelola state dan ViewModel.
- `url_launcher`: membuka tautan eksternal.
- `image_picker`: memilih foto dari galeri atau kamera.
- `sqflite`: mengelola SQLite pada perangkat.
- `path`: membantu pengelolaan lokasi file database.
- `flutter_test`: menjalankan pengujian Flutter.
- `flutter_lints`: membantu pemeriksaan kualitas kode.

Komunikasi HTTP yang sudah dikembangkan menggunakan kemampuan jaringan Dart.

---

## 5. Struktur Folder

Berikut gambaran struktur source code Flutter:

```text
flutter-studylog-mahasiswa/
│
├── android/
├── ios/
├── assets/
│   └── images/
│       └── profile.png
│
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   ├── app_router.dart
│   │   ├── routes.dart
│   │   └── theme.dart
│   │
│   ├── data/
│   │   ├── catatan_repository.dart
│   │   └── database_helper.dart
│   │
│   ├── models/
│   │   ├── catatan.dart
│   │   ├── course.dart
│   │   └── student.dart
│   │
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_dialog.dart
│   │   ├── contact_screen.dart
│   │   ├── course_detail_screen.dart
│   │   ├── catatan_lokal_screen.dart
│   │   └── study_log_screen.dart
│   │
│   ├── viewmodels/
│   │   ├── profile_viewmodel.dart
│   │   ├── catatan_view_model.dart
│   │   └── course_data.dart
│   │
│   ├── widgets/
│   ├── utils/
│   └── main.dart
│
├── test/
│   ├── navigation_test.dart
│   └── profile_viewmodel_test.dart
│
├── docs/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```

Struktur ini merupakan gambaran file utama. Folder platform dan file lain dapat ditambahkan sesuai kebutuhan pengembangan.

---

## 6. Persyaratan Instalasi

Untuk menjalankan aplikasi, siapkan:

1. Flutter SDK yang kompatibel dengan project.
2. Dart SDK yang sesuai.
3. Android Studio.
4. Android SDK.
5. Android Emulator atau perangkat Android.
6. Git.
7. Backend Laravel StudyLog.
8. MySQL atau MariaDB untuk backend.

Pada `pubspec.yaml`, project menggunakan:

```yaml
environment:
  sdk: ^3.8.1
```

Pastikan versi Flutter yang digunakan menyediakan Dart SDK yang memenuhi persyaratan tersebut.

---

## 7. Cara Instalasi Flutter

### Langkah 1 — Clone Repository

Buka PowerShell atau Terminal.

Jalankan:

```powershell
git clone https://github.com/wisnuwardhana822/flutter-studylog-mahasiswa.git
```

Masuk ke folder project:

```powershell
cd flutter-studylog-mahasiswa
```

### Langkah 2 — Periksa Flutter

Jalankan:

```powershell
flutter doctor
```

Periksa apakah Flutter SDK dan Android toolchain tersedia.

### Langkah 3 — Instal Dependensi

Jalankan:

```powershell
flutter pub get
```

Perintah tersebut akan mengunduh dependensi yang diperlukan aplikasi.

### Langkah 4 — Jalankan Emulator

Buka Android Studio dan jalankan Android Emulator.

Contoh perangkat pengujian awal:

```text
Pixel 7
Android API 34
```

Periksa perangkat:

```powershell
flutter devices
```

### Langkah 5 — Jalankan Aplikasi

```powershell
flutter run
```

**Penting:** Halaman yang membutuhkan data online memerlukan backend Laravel yang aktif. Catatan SQLite lokal menggunakan database pada perangkat.

Repository sudah memiliki folder platform, sehingga pada instalasi normal tidak perlu menjalankan `flutter create .`.

---

## 8. Instalasi Backend Laravel

Backend tersedia pada repository:

https://github.com/wisnuwardhana822/laravel-studylog-api

### Langkah 1 — Clone Backend

Buka Terminal baru:

```powershell
git clone https://github.com/wisnuwardhana822/laravel-studylog-api.git
```

Masuk ke folder:

```powershell
cd laravel-studylog-api
```

### Langkah 2 — Instal Dependensi Laravel

```powershell
composer install
```

### Langkah 3 — Buat File Environment

Di Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

### Langkah 4 — Konfigurasi Database

Buka file `.env` dan sesuaikan:

```dotenv
APP_NAME="StudyLog Mahasiswa"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://127.0.0.1:8888
APP_TIMEZONE=Asia/Makassar

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3307
DB_DATABASE=studylog_db
DB_USERNAME=root
DB_PASSWORD=
```

Port `3307` merupakan konfigurasi komputer pengembangan awal.

Jika MySQL pada komputer lain menggunakan port `3306`, ubah sesuai kondisi lokal.

### Langkah 5 — Buat Database

Pastikan layanan MySQL aktif.

Buat database:

```sql
CREATE DATABASE IF NOT EXISTS studylog_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
```

### Langkah 6 — Generate Application Key

```powershell
php artisan key:generate
```

### Langkah 7 — Jalankan Migration dan Seeder

Untuk database baru yang masih kosong:

```powershell
php artisan migrate --seed
```

Perintah tersebut membuat tabel dan memasukkan data mata kuliah awal.

### Langkah 8 — Jalankan Server Laravel

Cara umum:

```powershell
php artisan serve --host=127.0.0.1 --port=8888
```

Alternatif yang digunakan pada lingkungan pengembangan awal:

```powershell
php -S 127.0.0.1:8888 -t public public/index.php
```

Jalankan salah satu metode tersebut.

**Jangan menjalankan keduanya sekaligus pada port yang sama.**

Server Laravel perlu tetap aktif selama Flutter menggunakan API.

Panduan backend selengkapnya tersedia di `README.md` repository Laravel.

---

## 9. Menghubungkan Flutter dan Laravel

Pada pengembangan awal, aplikasi Flutter menggunakan alamat API:

```dart
const String apiBaseUrl = 'http://127.0.0.1:8888/api';
```

Alamat ini digunakan bersama **ADB reverse**, sehingga emulator Android dapat mengakses server Laravel pada komputer.

### Langkah 1 — Pastikan Laravel Aktif

Buka browser pada komputer:

```text
http://127.0.0.1:8888/api/courses
```

Jika berhasil, browser menampilkan respons JSON berisi data mata kuliah.

### Langkah 2 — Pastikan Emulator Terhubung

Pada Windows dengan lokasi Android SDK standar:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
```

Pastikan emulator muncul pada daftar perangkat.

### Langkah 3 — Jalankan ADB Reverse

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:8888 tcp:8888
```

Perintah ini meneruskan koneksi port `8888` dari emulator ke komputer.

### Langkah 4 — Jalankan Flutter

```powershell
flutter run
```

Sekarang aplikasi dapat mencoba mengambil data dari Laravel.

### Hal Penting

- ADB reverse tidak selalu bertahan setelah emulator dimulai ulang.
- Laravel dan MySQL harus tetap berjalan.
- Jika menggunakan Android fisik, konfigurasi koneksi mungkin berbeda.
- Jika port backend berubah, alamat API Flutter dan pengaturan ADB reverse perlu disesuaikan.
- Alamat `127.0.0.1` pada perangkat Android tidak otomatis menunjuk ke komputer tanpa mekanisme penghubung.

Konfigurasi koneksi ini ditujukan untuk pengembangan lokal.

---

## 10. Endpoint API

Backend Laravel menyediakan endpoint berikut:

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/api/courses` | Semua mata kuliah |
| GET | `/api/courses/today` | Jadwal hari ini |
| GET | `/api/courses/{code}` | Detail mata kuliah |
| GET | `/api/courses/{code}/notes` | Daftar catatan online |
| POST | `/api/courses/{code}/notes` | Tambah catatan online |
| DELETE | `/api/notes/{id}` | Hapus catatan online |
| GET | `/api/study-logs` | Riwayat StudyLog |
| POST | `/api/study-logs` | Tambah aktivitas belajar |
| GET | `/api/study-logs/stats` | Statistik StudyLog |
| DELETE | `/api/study-logs/{id}` | Hapus aktivitas belajar |

Contoh penggunaan:

```http
GET http://127.0.0.1:8888/api/courses/today
```

Contoh statistik:

```http
GET http://127.0.0.1:8888/api/study-logs/stats
```

Detail validasi dan struktur request POST dapat diperiksa pada `routes/api.php` dalam repository Laravel.

---

## 11. Data Jadwal Mata Kuliah

Data jadwal awal berasal dari kelas **IFB5J — Semester Ganjil 2026**.

| Hari | Kode | Mata Kuliah | Waktu |
|---|---|---|---|
| Senin | 111500 | Sistem Manajemen Basis Data | 19.00–20.30 |
| Selasa | 111100 | Penalaran Komputer | 19.00–20.30 |
| Selasa | 111400 | Simulasi dan Game Komputer | 20.30–22.00 |
| Rabu | 111300 | Robotika | 19.00–20.30 |
| Rabu | 110700 | Kriptografi | 20.30–22.00 |
| Kamis | 000800 | Penulisan dan Publikasi Ilmiah | 19.00–20.30 |
| Jumat | 110600 | Jaringan Nirkabel | 19.00–20.30 |
| Jumat | 111000 | Pemrograman Aplikasi Bergerak | 20.30–22.00 |

Seluruh waktu mengikuti zona waktu **WITA**.

Data ini disediakan oleh `CourseSeeder.php` pada repository backend Laravel.

File `lib/viewmodels/course_data.dart` merupakan bagian dari data lokal/struktur awal project. Sumber jadwal otomatis yang digunakan Beranda adalah REST API Laravel.

---

## 12. Penyimpanan Data

Aplikasi menggunakan dua mekanisme penyimpanan.

### A. MySQL — Online

MySQL menyimpan data backend:

```text
courses
course_notes
study_logs
```

Data diakses melalui REST API Laravel.

Fitur terkait:

- Jadwal perkuliahan.
- Detail mata kuliah.
- Catatan online per mata kuliah.
- Aktivitas dan statistik StudyLog.

### B. SQLite — Offline

SQLite digunakan oleh fitur **Catatan Perkuliahan Lokal**.

Fitur terkait:

- Tambah catatan.
- Lihat catatan.
- Edit catatan.
- Hapus catatan.

Database SQLite dibuat dan dikelola pada perangkat Android.

### Perbedaan Penting

**Catatan online dan catatan offline belum disinkronkan otomatis.**

Artinya:

- Catatan yang dibuat di SQLite tidak otomatis tersimpan di MySQL.
- Catatan yang dibuat melalui API Laravel tidak otomatis muncul di daftar SQLite.
- Menghapus aplikasi atau data aplikasinya dapat menghapus database lokal pada perangkat.

Sinkronisasi kedua penyimpanan dapat menjadi fitur pengembangan berikutnya.

---

## 13. Arsitektur Aplikasi

Alur umum sistem:

```text
                 PENGGUNA
                    |
                    v
            APLIKASI FLUTTER
                    |
          +---------+---------+
          |                   |
          v                   v
   FITUR ONLINE         FITUR OFFLINE
          |                   |
          v                   v
     REST API              SQLite
      Laravel           Database Lokal
          |
          v
    MySQL / MariaDB
          |
          v
   Jadwal, Catatan Online,
   dan Aktivitas StudyLog
```

Dengan arsitektur ini, fitur lokal dan fitur yang membutuhkan server dapat dikembangkan secara terpisah.

---

## 14. Pemetaan Materi Navigation, Lifecycle, dan ViewModel

Project tetap mempertahankan materi inti tugas Pemrograman Aplikasi Bergerak.

| Konsep | Implementasi Flutter |
|---|---|
| Destination / Route | `AppRoutes` |
| Navigation Host | `onGenerateRoute` |
| Navigasi antarlayar | `Navigator.pushNamed()` |
| Kembali ke layar sebelumnya | `Navigator.pop()` |
| Pengiriman argument | `RouteSettings.arguments` |
| ViewModel | `ChangeNotifier` |
| State management | `provider` |
| Membaca state | `context.watch()` |
| Mengirim aksi | `context.read()` |
| Lifecycle | `WidgetsBindingObserver` |
| Database lokal | `sqflite` |
| Komunikasi server | HTTP melalui Dart |

Fitur-fitur baru merupakan pengembangan dari fondasi aplikasi profil mahasiswa yang sudah dibuat sebelumnya.

---

## 15. Pengujian

### 15.1 Analisis Kode Flutter

Jalankan:

```powershell
flutter analyze
```

Gunakan hasil analisis untuk menemukan error dan peringatan kode.

### 15.2 Pengujian Otomatis

Jalankan:

```powershell
flutter test
```

Pada pengembangan awal, hasil pengujian menunjukkan:

```text
+12: All tests passed!
```

Artinya, **12 pengujian yang tersedia saat itu berhasil dijalankan**.

Hasil tersebut tidak menggantikan pengujian seluruh koneksi API, database, dan perangkat secara langsung.

### 15.3 Pengujian Manual

Skenario yang perlu diperiksa:

1. Buka aplikasi Flutter.
2. Pastikan halaman Beranda tampil.
3. Buka halaman Profil.
4. Ubah informasi profil melalui formulir.
5. Uji validasi dengan mengosongkan kolom wajib.
6. Buka halaman Kontak.
7. Periksa jadwal mata kuliah hari ini.
8. Buka detail salah satu mata kuliah.
9. Tambahkan dan hapus catatan online.
10. Buka Catatan Perkuliahan Lokal.
11. Tambahkan catatan SQLite.
12. Baca dan ubah catatan.
13. Hapus catatan setelah konfirmasi.
14. Buka StudyLog.
15. Tambahkan aktivitas belajar.
16. Periksa riwayat dan statistik belajar.
17. Periksa perilaku fitur offline saat koneksi terputus.

Pengujian koneksi backend harus dilakukan ketika MySQL dan Laravel aktif.

---

## 16. Tampilan Aplikasi

Aplikasi menggunakan kombinasi warna yang mempertahankan identitas visual tugas awal.

Warna utama:

```text
Navy  : #002060
Merah : #E31B23
Kuning: #F4C400
```

Tampilan menggunakan komponen antarmuka seperti:

- Kartu informasi.
- Tombol navigasi.
- Formulir dengan validasi.
- Dialog konfirmasi.
- Pesan status operasi.
- Indikator loading.
- Tampilan data kosong.

### Screenshot

Dokumentasi screenshot tugas awal tersedia pada folder:

```text
docs/screenshots/
```

Beberapa screenshot lama mungkin belum menggambarkan fitur StudyLog dan SQLite terbaru.

Screenshot terbaru dapat ditambahkan ke folder tersebut tanpa menghapus dokumentasi sebelumnya.

---

## 17. Kolaborasi Melalui GitHub

Repository ini bersifat **Public**, sehingga developer lain dapat melihat dan mengunduh source code.

Namun, status Public tidak otomatis memberikan izin untuk melakukan `git push` ke repository utama.

### Mengambil Source Code

```powershell
git clone https://github.com/wisnuwardhana822/flutter-studylog-mahasiswa.git
```

### Membuat Branch Pengembangan

```powershell
git switch -c feature/nama-fitur
```

### Menyimpan Perubahan

```powershell
git add .
git commit -m "feat: deskripsi fitur baru"
```

### Mengirim Perubahan

```powershell
git push -u origin feature/nama-fitur
```

Perintah push memerlukan izin tulis pada repository.

Jika belum memiliki izin, developer dapat menggunakan fork dan mengirim Pull Request.

### Rekomendasi Kerja Tim

- Gunakan branch terpisah untuk fitur baru.
- Jangan langsung mengubah branch `main` tanpa pengujian.
- Jalankan `flutter analyze` dan `flutter test` sebelum mengirim perubahan.
- Tulis commit message yang menjelaskan perubahan.
- Jangan mengunggah password, token, atau file konfigurasi rahasia.

---

## 18. Keamanan

Project ini merupakan **prototipe pembelajaran**, bukan aplikasi produksi.

Hal yang perlu diperhatikan:

1. Jangan menuliskan password database pada source code Flutter.
2. Jangan mengunggah file `.env` Laravel.
3. Jangan mengekspos endpoint Laravel yang belum dilindungi langsung ke internet.
4. Gunakan autentikasi dan otorisasi sebelum digunakan oleh banyak pengguna.
5. Gunakan HTTPS untuk lingkungan produksi.
6. Jangan menyimpan kredensial rahasia di repository Public.
7. Konfigurasi HTTP lokal dan izin cleartext Android yang digunakan untuk pengembangan perlu ditinjau sebelum aplikasi dipublikasikan.

API Laravel pada tahap ini belum menerapkan autentikasi dan pembatasan akses berdasarkan pengguna.

---

## 19. Pengembangan Selanjutnya

Project dapat dikembangkan dengan fitur tambahan, seperti:

1. Autentikasi dan manajemen akun.
2. Sinkronisasi catatan offline dan online.
3. Notifikasi jadwal perkuliahan.
4. Pengingat aktivitas belajar.
5. Pengaturan alamat API berdasarkan lingkungan.
6. Pengelolaan jadwal oleh administrator.
7. Peningkatan keamanan API.
8. Pengujian otomatis untuk komunikasi Flutter–Laravel.
9. Pengujian pada perangkat fisik.
10. Persiapan deployment backend dan rilis Android.

Fitur-fitur tersebut merupakan rencana pengembangan dan **belum dinyatakan selesai**.

---

## 20. Troubleshooting

### A. Flutter Tidak Bisa Dijalankan

Jalankan:

```powershell
flutter doctor
```

Pastikan Android SDK dan perangkat sudah terdeteksi.

Kemudian:

```powershell
flutter pub get
```

### B. Jadwal Kuliah Tidak Muncul

Periksa:

- MySQL aktif.
- Laravel aktif.
- Endpoint `/api/courses/today` dapat diakses.
- ADB reverse aktif.
- Alamat API pada Flutter sesuai.

### C. Koneksi API Gagal

Pada emulator Android yang menggunakan ADB reverse:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:8888 tcp:8888
```

Pastikan backend masih berjalan pada port `8888`.

### D. SQLite Tidak Menyimpan Catatan

Periksa:

- Dependensi `sqflite` telah terinstal.
- Aplikasi berjalan pada platform yang didukung.
- Struktur tabel dan proses inisialisasi database benar.
- Tidak ada exception pada log aplikasi.

### E. Data MySQL Kosong

Pada folder backend Laravel, jalankan:

```powershell
php artisan migrate
php artisan db:seed
```

Periksa juga konfigurasi `.env`.

**Hindari `migrate:fresh` pada database yang sudah memiliki data penting.**

### F. Pengujian Flutter Gagal

Jalankan:

```powershell
flutter test
```

Periksa nama file dan lokasi error yang muncul.

Beberapa pengujian tampilan perlu disesuaikan apabila struktur navigasi atau isi halaman berubah.

---

## 21. Status Project

Status berdasarkan pengembangan dan pengujian yang telah dilakukan:

| Komponen | Status |
|---|---|
| Profil mahasiswa | Diimplementasikan |
| Edit profil | Diimplementasikan |
| Kontak | Diimplementasikan |
| Lifecycle | Diimplementasikan |
| Jadwal kuliah otomatis | Diimplementasikan |
| Detail mata kuliah | Diimplementasikan |
| Catatan online | Diimplementasikan |
| Catatan offline SQLite | Diimplementasikan |
| StudyLog | Diimplementasikan |
| Validasi formulir | Diimplementasikan |
| Pengujian Flutter | 12 tes lulus pada pengujian terakhir |
| Repository Flutter | Tersedia di GitHub |
| Repository Laravel | Tersedia di GitHub |
| Sinkronisasi offline-online | Belum tersedia |
| Autentikasi API | Belum tersedia |
| Pengujian instalasi pada komputer lain | Belum diverifikasi |

---

## 22. Informasi Akademik

Project ini dikembangkan sebagai bagian dari pembelajaran:

**Mata Kuliah:** Pemrograman Aplikasi Bergerak  
**Program Studi:** Informatika  
**Perguruan Tinggi:** Universitas Mulia

Pengembangan awal mempelajari:

- Navigation.
- Lifecycle.
- ViewModel.
- State management.
- Form validation.

Fitur tambahan kemudian dikembangkan untuk memperluas aplikasi menjadi StudyLog Mahasiswa.

---

## 23. Penutup

StudyLog Mahasiswa merupakan aplikasi mobile berbasis Flutter yang menggabungkan pengelolaan jadwal perkuliahan, catatan offline, dan pencatatan aktivitas belajar melalui integrasi Laravel REST API dan SQLite.

Repository ini dapat digunakan sebagai dasar pembelajaran dan pengembangan kolaboratif.

Untuk menjalankan seluruh fitur online, pastikan backend Laravel dan database MySQL telah dikonfigurasi dengan benar.

**Repository Flutter:**  
https://github.com/wisnuwardhana822/flutter-studylog-mahasiswa

**Repository Laravel:**  
https://github.com/wisnuwardhana822/laravel-studylog-api