<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Membuat tabel catatan mata kuliah.
     */
    public function up(): void
    {
        Schema::create('course_notes', function (Blueprint $table) {

            // ID unik untuk setiap catatan
            $table->id();

            // Relasi ke tabel courses
            $table->foreignId('course_id')
                ->constrained('courses')
                ->cascadeOnDelete();

            // Judul catatan
            $table->string('title', 150);

            // Isi catatan
            $table->text('content');

            // Waktu pembuatan dan perubahan
            $table->timestamps();

            // Mempercepat pencarian catatan per mata kuliah
            $table->index('course_id');
        });
    }

    /**
     * Menghapus tabel apabila migration dibatalkan.
     */
    public function down(): void
    {
        Schema::dropIfExists('course_notes');
    }
};