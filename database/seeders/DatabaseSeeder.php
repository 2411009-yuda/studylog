<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

/**
 * DatabaseSeeder
 *
 * Seeder utama aplikasi StudyLog Mahasiswa.
 *
 * Digunakan untuk menjalankan seeder data awal
 * melalui perintah:
 *
 * php artisan db:seed
 *
 * atau:
 *
 * php artisan migrate --seed
 */
class DatabaseSeeder extends Seeder
{
    /**
     * Menjalankan seluruh seeder aplikasi.
     */
    public function run(): void
    {
        $this->call([
            CourseSeeder::class,
        ]);
    }
}