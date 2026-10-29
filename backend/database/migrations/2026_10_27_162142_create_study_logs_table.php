<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Membuat tabel aktivitas belajar mahasiswa.
     */
    public function up(): void
    {
        Schema::create('study_logs', function (Blueprint $table) {

            // ID utama aktivitas belajar.
            $table->id();

            // Menghubungkan aktivitas dengan mata kuliah.
            $table->foreignId('course_id')
                ->constrained('courses')
                ->cascadeOnDelete();

            // Tanggal aktivitas belajar dilakukan.
            $table->date('studied_on');

            // Durasi belajar dalam satuan menit.
            $table->unsignedInteger('duration_minutes');

            // Materi atau topik yang dipelajari.
            $table->string('topic', 200);

            // Catatan tambahan, hasil, atau kendala belajar.
            // Boleh kosong.
            $table->text('notes')->nullable();

            // Tanggal pembuatan dan perubahan data.
            $table->timestamps();

            // Index untuk mempercepat pengambilan
            // riwayat aktivitas berdasarkan tanggal.
            $table->index('studied_on');

            // Index gabungan untuk riwayat per mata kuliah.
            $table->index([
                'course_id',
                'studied_on'
            ]);
        });
    }

    /**
     * Menghapus tabel jika migration di-rollback.
     */
    public function down(): void
    {
        Schema::dropIfExists('study_logs');
    }
};