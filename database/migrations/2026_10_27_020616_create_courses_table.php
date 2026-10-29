
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Membuat tabel mata kuliah.
     */
    public function up(): void
    {
        Schema::create('courses', function (Blueprint $table) {
            $table->id();

            $table->string('course_code', 20)->unique();
            $table->string('course_name');
            $table->unsignedTinyInteger('credits');
            $table->string('class_name', 20)->default('IFB5J');

            // Senin = 1, Selasa = 2, ..., Minggu = 7
            $table->unsignedTinyInteger('day_of_week');

            $table->time('start_time');
            $table->time('end_time');

            $table->string('room');
            $table->string('lecturer');
            $table->string('semester')->default('Ganjil 2026');

            $table->timestamps();

            $table->index(['day_of_week', 'start_time']);
        });
    }

    /**
     * Menghapus tabel jika migration dibatalkan.
     */
    public function down(): void
    {
        Schema::dropIfExists('courses');
    }
};
