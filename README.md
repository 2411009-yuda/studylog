# StudyLog Mahasiswa — Laravel REST API

Backend REST API berbasis **Laravel 12 dan MySQL** untuk aplikasi mobile **StudyLog Mahasiswa** yang dikembangkan menggunakan Flutter.

Backend ini menyediakan data jadwal perkuliahan, informasi mata kuliah, catatan perkuliahan online, riwayat aktivitas belajar, dan statistik belajar.

## 1. Tentang Project

StudyLog Mahasiswa merupakan aplikasi pendukung kegiatan perkuliahan yang membantu mahasiswa mengelola jadwal, menyimpan materi, dan mencatat aktivitas belajar.

Project terdiri atas dua bagian utama:

| Komponen | Teknologi | Fungsi |
|---|---|---|
| Mobile Application | Flutter / Dart | Antarmuka aplikasi Android |
| Backend API | Laravel / PHP | Menyediakan REST API |
| Database Online | MySQL / MariaDB | Menyimpan mata kuliah, catatan online, dan StudyLog |
| Database Offline | SQLite pada Flutter | Menyimpan catatan lokal di perangkat |

Repository Flutter:

https://github.com/wisnuwardhana822/flutter-studylog-mahasiswa

Repository Laravel:

https://github.com/wisnuwardhana822/laravel-studylog-api

## 2. Fitur Backend

### A. Jadwal Perkuliahan

- Menampilkan seluruh mata kuliah.
- Menampilkan jadwal perkuliahan hari ini secara otomatis.
- Menampilkan detail mata kuliah.
- Menggunakan zona waktu **Asia/Makassar (WITA)**.

### B. Catatan Perkuliahan Online

- Melihat catatan berdasarkan mata kuliah.
- Menambahkan catatan baru.
- Menghapus catatan.
- Memvalidasi judul dan isi catatan.

### C. StudyLog

- Menampilkan riwayat aktivitas belajar.
- Mencatat aktivitas belajar baru.
- Menyimpan tanggal, mata kuliah, durasi, dan materi yang dipelajari.
- Menampilkan statistik aktivitas belajar.
- Menghapus aktivitas belajar.

### D. Catatan Offline

Fitur catatan offline tidak menggunakan Laravel. Data disimpan menggunakan **SQLite pada aplikasi Flutter**.

Catatan offline dan catatan online merupakan dua penyimpanan yang berbeda. Project ini belum menerapkan sinkronisasi otomatis di antara keduanya.

## 3. Teknologi

Teknologi yang digunakan dalam pengembangan:

- PHP 8.3
- Laravel 12
- Composer
- MySQL / MariaDB
- REST API berbasis JSON
- Flutter sebagai aplikasi client
- Git dan GitHub

## 4. Struktur Project

```text
laravel-studylog-api/
│
├── app/
│   ├── Http/
│   ├── Models/
│   └── Providers/
│
├── bootstrap/
│   └── app.php
│
├── config/
│
├── database/
│   ├── migrations/
│   │   ├── create_users_table.php
│   │   ├── create_cache_table.php
│   │   ├── create_jobs_table.php
│   │   ├── create_courses_table.php
│   │   ├── create_course_notes_table.php
│   │   └── create_study_logs_table.php
│   │
│   └── seeders/
│       ├── CourseSeeder.php
│       └── DatabaseSeeder.php
│
├── public/
│   └── index.php
│
├── routes/
│   ├── api.php
│   ├── web.php
│   └── console.php
│
├── storage/
├── tests/
│
├── .env.example
├── .gitignore
├── artisan
├── composer.json
├── composer.lock
└── README.md
```

Nama file migration sebenarnya memiliki awalan timestamp. Struktur di atas disederhanakan agar mudah dipahami.

## 5. Persyaratan Instalasi

Sebelum menjalankan backend, siapkan:

1. PHP 8.2 atau lebih baru yang kompatibel dengan Laravel 12.
2. Composer.
3. MySQL atau MariaDB.
4. Git.
5. Ekstensi PHP yang diperlukan Laravel, termasuk PDO MySQL.
6. Android Studio dan Flutter SDK apabila ingin menjalankan aplikasi mobile.

Lingkungan pengembangan awal menggunakan:

```text
Windows
PHP 8.3
Laravel 12
MySQL/MariaDB melalui XAMPP
Database: studylog_db
MySQL Port: 3306
Laravel API Port: 8000
Timezone: Asia/Makassar
```

Konfigurasi komputer lain dapat berbeda.

## 6. Instalasi Backend Laravel

### Langkah 1 — Clone Repository

Buka PowerShell atau Terminal.

```powershell
git clone https://github.com/wisnuwardhana822/laravel-studylog-api.git
```

Masuk ke folder project:

```powershell
cd laravel-studylog-api
```

### Langkah 2 — Instal Dependensi

Jalankan:

```powershell
composer install
```

Perintah tersebut menginstal dependensi PHP sesuai `composer.lock`.

Jika PHP atau Composer belum tersedia melalui PATH, sesuaikan perintah dengan lokasi instalasinya.

### Langkah 3 — Buat File Environment

Pada Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Untuk macOS/Linux:

```bash
cp .env.example .env
```

File `.env` digunakan untuk konfigurasi lokal dan **tidak boleh diunggah ke repository publik**.

### Langkah 4 — Konfigurasi Database

Buka file `.env`.

Sesuaikan bagian berikut:

```dotenv
APP_NAME="StudyLog Mahasiswa"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://IP_LAPTOP:8000
APP_TIMEZONE=Asia/Makassar

DB_CONNECTION=mysql
DB_HOST=IP_LAPTOP
DB_PORT=3307
DB_DATABASE=studylog_db
DB_USERNAME=root
DB_PASSWORD=
```

**Penting:**

- Port `3307` digunakan pada komputer pengembangan awal.
- Jika MySQL menggunakan port `3306`, ubah `DB_PORT=3306`.
- Isi `DB_USERNAME` dan `DB_PASSWORD` sesuai konfigurasi MySQL masing-masing.
- `APP_DEBUG=true` hanya untuk lingkungan pengembangan lokal.

### Langkah 5 — Buat Database

Jalankan MySQL atau MariaDB melalui XAMPP atau layanan database lainnya.

Buat database dengan nama:

```sql
CREATE DATABASE IF NOT EXISTS studylog_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
```

Database dapat dibuat melalui phpMyAdmin pada menu **SQL**.

Pastikan server MySQL sudah berjalan sebelum melanjutkan.

### Langkah 6 — Generate Application Key

Jalankan:

```powershell
php artisan key:generate
```

Perintah ini membuat `APP_KEY` khusus untuk instalasi tersebut.

Jangan menyalin `APP_KEY` dari komputer pengembang lain.

### Langkah 7 — Buat Tabel Database

Jalankan:

```powershell
php artisan migrate
```

Laravel akan membuat tabel sesuai migration yang tersedia.

Tabel utama aplikasi meliputi:

```text
courses
course_notes
study_logs
```

Laravel juga memiliki tabel pendukung seperti `users`, `cache`, dan `jobs`.

### Langkah 8 — Masukkan Data Mata Kuliah

Jalankan:

```powershell
php artisan db:seed
```

Seeder akan memanggil `CourseSeeder` untuk mengisi delapan mata kuliah awal.

Sebagai alternatif, pada **database baru yang masih kosong**, langkah migrasi dan seeding dapat digabungkan:

```powershell
php artisan migrate --seed
```

**Jangan menjalankan `migrate:fresh` pada database yang berisi data penting.** Perintah tersebut menghapus tabel sebelum membuatnya ulang.

## 7. Data Mata Kuliah Awal

Data mata kuliah pada seeder berasal dari jadwal kelas **IFB5J, Semester Ganjil 2026**.

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

Seluruh jadwal menggunakan **Waktu Indonesia Tengah (WITA)**.

Data dosen, ruangan, SKS, dan informasi lainnya tersedia dalam `CourseSeeder.php`.

## 8. Menjalankan Laravel

### Opsi A — Laravel Development Server

Jalankan:

```powershell
php artisan serve --host=IP_LAPTOP --port=8000
```

Jika server berhasil berjalan, backend dapat diakses melalui:

```text
http://IP_LAPTOP:8000
```

### Opsi B — PHP Built-in Server

Pada lingkungan pengembangan awal, server dijalankan menggunakan PHP built-in server dengan `public/index.php` sebagai router.

Di Windows PowerShell, dari folder Laravel:

```powershell
php -S IP_LAPTOP:8000 -t public public/index.php
```

Gunakan opsi ini sebagai alternatif apabila `artisan serve` mengalami kendala di lingkungan lokal.

**Catatan:** Kedua metode tersebut ditujukan untuk pengembangan, bukan server produksi.

Biarkan Terminal server tetap berjalan selama aplikasi Flutter mengakses API.

## 9. Endpoint REST API

Backend menyediakan endpoint berikut:

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/api/courses` | Menampilkan seluruh mata kuliah |
| GET | `/api/courses/today` | Menampilkan jadwal hari ini |
| GET | `/api/courses/{code}` | Menampilkan detail mata kuliah |
| GET | `/api/courses/{code}/notes` | Menampilkan catatan mata kuliah |
| POST | `/api/courses/{code}/notes` | Menambahkan catatan online |
| DELETE | `/api/notes/{id}` | Menghapus catatan online |
| GET | `/api/study-logs` | Menampilkan aktivitas belajar |
| POST | `/api/study-logs` | Menambahkan aktivitas belajar |
| GET | `/api/study-logs/stats` | Menampilkan statistik belajar |
| DELETE | `/api/study-logs/{id}` | Menghapus aktivitas belajar |

Jumlah endpoint yang telah didaftarkan pada project ini adalah **10 route API**.

### Contoh Mengambil Semua Mata Kuliah

Request:

```http
GET http://IP_LAPTOP:8000/api/courses
```

### Contoh Jadwal Hari Ini

Request:

```http
GET http://IP_LAPTOP:8000/api/courses/today
```

Endpoint ini menentukan jadwal berdasarkan tanggal dan hari di zona waktu Asia/Makassar.

### Contoh Detail Mata Kuliah

Request:

```http
GET http://IP_LAPTOP:80008000800080008/api/courses/111100
```

Kode `111100` merujuk pada mata kuliah Penalaran Komputer.

### Contoh Catatan Online

Request:

```http
GET http://IP_LAPTOP:80008000800080008/api/courses/111100/notes
```

### Contoh StudyLog

Request:

```http
GET http://IP_LAPTOP:80008000800080008/api/study-logs
```

### Contoh Statistik StudyLog

Request:

```http
GET http://IP_LAPTOP:80008000800080008/api/study-logs/stats
```

Endpoint penambahan data menggunakan metode POST dan menerima data JSON sesuai validasi pada `routes/api.php`.

## 10. Menghubungkan Flutter dengan Laravel

Repository Flutter:

https://github.com/wisnuwardhana822/flutter-studylog-mahasiswa

### A. Clone Project Flutter

```powershell
git clone https://github.com/wisnuwardhana822/flutter-studylog-mahasiswa.git
```

Masuk ke folder project:

```powershell
cd flutter-studylog-mahasiswa
```

Instal dependensi Flutter:

```powershell
flutter pub get
```

### B. Jalankan Android Emulator

Gunakan emulator Android melalui Android Studio.

Pastikan Laravel masih berjalan pada port `80008000800080008`.

### C. Konfigurasi Alamat API

Pada pengembangan awal, aplikasi Flutter menggunakan:

```dart
const String apiBaseUrl = 'http://IP_LAPTOP:80008000800080008/api';
```

Alamat ini digunakan bersama **ADB reverse** untuk menghubungkan emulator dengan server Laravel pada komputer.

Karena alamat API masih dikonfigurasi pada source code, developer berikutnya harus memeriksa konfigurasi tersebut ketika menggunakan perangkat atau jaringan berbeda.

### D. Aktifkan ADB Reverse

Untuk Windows dengan Android SDK pada lokasi standar:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
```

Pastikan emulator terdeteksi.

Kemudian:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:80008000800080008 tcp:80008000800080008
```

Dengan konfigurasi ini, koneksi dari emulator ke:

```text
http://IP_LAPTOP:80008000800080008
```

diteruskan ke port `80008000800080008` pada komputer host.

**Perhatian:**

- ADB reverse perlu disiapkan kembali jika koneksi emulator terputus.
- Server Laravel harus tetap berjalan.
- Perangkat Android fisik memerlukan konfigurasi koneksi yang sesuai.
- Alamat `IP_LAPTOP` di perangkat tidak otomatis menunjuk komputer host tanpa mekanisme seperti ADB reverse.

### E. Jalankan Aplikasi Flutter

```powershell
flutter run
```

Jika perangkat Android sudah terdeteksi dan koneksi backend tersedia, aplikasi dapat mengambil jadwal kuliah melalui REST API.

## 11. Pengujian

### Memeriksa Route Laravel

```powershell
php artisan route:list --path=api
```

Pastikan seluruh endpoint API yang diperlukan terdaftar.

### Menguji API

Buka browser dan akses:

```text
http://IP_LAPTOP:80008000800080008/api/courses
```

Kemudian:

```text
http://IP_LAPTOP:80008000800080008/api/courses/today
```

Jika berhasil, Laravel mengembalikan respons JSON.

### Pengujian Flutter

Pada folder repository Flutter:

```powershell
flutter analyze
```

Kemudian:

```powershell
flutter test
```

Pada lingkungan pengembangan awal, **12 pengujian Flutter telah berhasil dijalankan**.

Hasil pengujian dapat berubah apabila kode atau dependensi diperbarui.

## 12. Catatan Database

Terdapat dua tempat penyimpanan data yang berbeda.

### MySQL — Backend Online

MySQL menyimpan:

- Data mata kuliah.
- Catatan perkuliahan online.
- Aktivitas belajar StudyLog.

### SQLite — Flutter Offline

SQLite menyimpan:

- Catatan lokal mahasiswa.
- Informasi catatan yang dibuat melalui fitur Catatan Perkuliahan Offline.

**Penting:** Data SQLite tersimpan pada perangkat Android. Data ini tidak otomatis masuk ke MySQL.

Repository GitHub berisi source code dan struktur database, bukan seluruh data pribadi yang ada pada database lokal pengembang.

Ketika repository di-clone pada komputer baru, migration membuat tabel dan seeder membuat data mata kuliah awal. Catatan pribadi dan riwayat belajar lama tidak otomatis tersedia.

## 13. Keamanan

Repository ini ditujukan sebagai project pembelajaran dan prototipe pengembangan.

Hal-hal yang harus diperhatikan:

- Jangan mengunggah file `.env`.
- Jangan membagikan `APP_KEY` atau password database.
- Jangan menjalankan `APP_DEBUG=true` pada server publik.
- Endpoint API saat ini belum memiliki autentikasi pengguna dan otorisasi kepemilikan data.
- Jangan mengekspos API ini secara langsung ke internet tanpa pengamanan tambahan.
- Gunakan HTTPS dan mekanisme autentikasi yang sesuai apabila dikembangkan untuk produksi.
- Gunakan kredensial database yang berbeda untuk setiap lingkungan.

## 14. Pengembangan Selanjutnya

Beberapa pengembangan yang dapat dilakukan:

1. Menambahkan autentikasi dan otorisasi pengguna.
2. Memisahkan konfigurasi alamat API Flutter dari kode tampilan.
3. Menambahkan pengujian otomatis untuk endpoint Laravel.
4. Mengembangkan sinkronisasi catatan offline dan online.
5. Menambahkan fitur notifikasi jadwal kuliah.
6. Menambahkan pengelolaan mata kuliah dan jadwal melalui panel admin.
7. Meningkatkan keamanan, validasi, dan penanganan kesalahan API.
8. Menyiapkan konfigurasi deployment untuk lingkungan produksi.

## 15. Kolaborasi

Developer lain dapat melanjutkan project melalui langkah berikut:

```powershell
git clone https://github.com/wisnuwardhana822/laravel-studylog-api.git
```

Setelah mengubah kode:

```powershell
git status
git add .
git commit -m "Deskripsi perubahan"
```

Untuk mengirim perubahan ke repository utama, diperlukan akses tulis sebagai kolaborator atau penggunaan Pull Request dari fork repository.

Disarankan mengembangkan fitur baru pada branch terpisah sebelum menggabungkannya ke branch `main`.

## 16. Troubleshooting

### Tidak dapat terhubung ke database

Periksa:

- MySQL sedang berjalan.
- Database `studylog_db` sudah dibuat.
- Port MySQL pada `.env` benar.
- Username dan password database sesuai.

### API tidak dapat diakses

Periksa:

- Laravel sudah dijalankan.
- Port `80008000800080008` tidak digunakan aplikasi lain.
- URL API benar.
- Firewall tidak menghalangi koneksi yang diperlukan.

### Flutter tidak dapat mengambil jadwal

Periksa:

- Endpoint Laravel dapat diakses melalui browser komputer.
- Emulator terdeteksi melalui ADB.
- ADB reverse sudah diaktifkan.
- Alamat API pada Flutter sesuai.
- Izin internet tersedia pada aplikasi Android.

### Tabel database belum tersedia

Jalankan:

```powershell
php artisan migrate
```

### Data mata kuliah masih kosong

Jalankan:

```powershell
php artisan db:seed
```

Jangan menggunakan `migrate:fresh` jika database telah berisi data yang perlu dipertahankan.

---

## Informasi Repository

**Project:** StudyLog Mahasiswa  
**Backend:** Laravel REST API  
**Database:** MySQL / MariaDB  
**Mobile Client:** Flutter  
**Timezone:** Asia/Makassar (WITA)  
**Tujuan:** Pembelajaran, kolaborasi, dan pengembangan aplikasi mobile perkuliahan

Repository Flutter:

https://github.com/wisnuwardhana822/flutter-studylog-mahasiswa

Repository Backend:

https://github.com/wisnuwardhana822/laravel-studylog-api
