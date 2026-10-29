<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CourseSeeder extends Seeder
{
    public function run(): void
    {
        $courses = [
            [
                'course_code' => '111500',
                'course_name' => 'Sistem Manajemen Basis Data',
                'credits' => 3,
                'class_name' => 'IFB5J',
                'day_of_week' => 1,
                'start_time' => '19:00:00',
                'end_time' => '20:30:00',
                'room' => 'LAB B (FIKOM)',
                'lecturer' => 'Nasruddin Bin Idris, S.Kom., M.Kom.',
                'semester' => 'Ganjil 2026',
            ],
            [
                'course_code' => '111100',
                'course_name' => 'Penalaran Komputer',
                'credits' => 3,
                'class_name' => 'IFB5J',
                'day_of_week' => 2,
                'start_time' => '19:00:00',
                'end_time' => '20:30:00',
                'room' => 'A201',
                'lecturer' => 'Isa Rosita, S.Kom., M.Cs.',
                'semester' => 'Ganjil 2026',
            ],
            [
                'course_code' => '111400',
                'course_name' => 'Simulasi dan Game Komputer',
                'credits' => 3,
                'class_name' => 'IFB5J',
                'day_of_week' => 2,
                'start_time' => '20:30:00',
                'end_time' => '22:00:00',
                'room' => 'LAB A (FIKOM)',
                'lecturer' => 'Heruzulkifli Rowa, S.Kom., M.Kom.',
                'semester' => 'Ganjil 2026',
            ],
            [
                'course_code' => '111300',
                'course_name' => 'Robotika',
                'credits' => 3,
                'class_name' => 'IFB5J',
                'day_of_week' => 3,
                'start_time' => '19:00:00',
                'end_time' => '20:30:00',
                'room' => 'LAB ROBOTIK (FIKOM)',
                'lecturer' => "Muhammad Safi'i, S.Kom., M.Kom.",
                'semester' => 'Ganjil 2026',
            ],
            [
                'course_code' => '110700',
                'course_name' => 'Kriptografi',
                'credits' => 3,
                'class_name' => 'IFB5J',
                'day_of_week' => 3,
                'start_time' => '20:30:00',
                'end_time' => '22:00:00',
                'room' => 'A201',
                'lecturer' => "Muhammad Safi'i, S.Kom., M.Kom.",
                'semester' => 'Ganjil 2026',
            ],
            [
                'course_code' => '000800',
                'course_name' => 'Penulisan dan Publikasi Ilmiah',
                'credits' => 2,
                'class_name' => 'IFB5J',
                'day_of_week' => 4,
                'start_time' => '19:00:00',
                'end_time' => '20:30:00',
                'room' => 'A203',
                'lecturer' => 'Yustian Servanda, S.Kom., M.Kom.',
                'semester' => 'Ganjil 2026',
            ],
            [
                'course_code' => '110600',
                'course_name' => 'Jaringan Nirkabel',
                'credits' => 3,
                'class_name' => 'IFB5J',
                'day_of_week' => 5,
                'start_time' => '19:00:00',
                'end_time' => '20:30:00',
                'room' => 'LAB JARINGAN (FIKOM)',
                'lecturer' => 'Maradona, S.Kom., M.Kom.',
                'semester' => 'Ganjil 2026',
            ],
            [
                'course_code' => '111000',
                'course_name' => 'Pemrograman Aplikasi Bergerak',
                'credits' => 3,
                'class_name' => 'IFB5J',
                'day_of_week' => 5,
                'start_time' => '20:30:00',
                'end_time' => '22:00:00',
                'room' => 'LAB A (FIKOM)',
                'lecturer' => 'Pramudya Prima Insan, S.Kom., M.Kom.',
                'semester' => 'Ganjil 2026',
            ],
        ];

        foreach ($courses as $course) {
            $existingCourse = DB::table('courses')
                ->where('course_code', $course['course_code'])
                ->first();

            if ($existingCourse) {
                DB::table('courses')
                    ->where('course_code', $course['course_code'])
                    ->update(array_merge($course, [
                        'updated_at' => now(),
                    ]));
            } else {
                DB::table('courses')->insert(array_merge($course, [
                    'created_at' => now(),
                    'updated_at' => now(),
                ]));
            }
        }
    }
}
