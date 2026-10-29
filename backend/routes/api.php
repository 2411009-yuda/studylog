<?php

use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Validator;

/*
|--------------------------------------------------------------------------
| KONFIGURASI STUDYLOG
|--------------------------------------------------------------------------
|
| Seluruh tanggal aktivitas menggunakan zona waktu WITA.
|
*/

function studyLogNow(): Carbon
{
    return Carbon::now('Asia/Makassar');
}

/*
|--------------------------------------------------------------------------
| 1. DAFTAR SEMUA MATA KULIAH
|--------------------------------------------------------------------------
|
| GET /api/courses
|
*/


Route::get('/courses', function () {

    $courses = DB::table('courses')
        ->orderBy('day_of_week')
        ->orderBy('start_time')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $courses,
    ]);

});

/*
|--------------------------------------------------------------------------
| 2. JADWAL KULIAH HARI INI
|--------------------------------------------------------------------------
|
| GET /api/courses/today
|
*/

Route::get('/courses/today', function () {

    $now = studyLogNow();

    $courses = DB::table('courses')
        ->where('day_of_week', $now->dayOfWeekIso)
        ->orderBy('start_time')
        ->get();

    return response()->json([
        'success' => true,
        'date' => $now->toDateString(),
        'day_of_week' => $now->dayOfWeekIso,
        'timezone' => 'Asia/Makassar',
        'server_time' => $now->toIso8601String(),
        'data' => $courses,
    ]);

});

/*
|--------------------------------------------------------------------------
| 3. DETAIL MATA KULIAH
|--------------------------------------------------------------------------
|
| GET /api/courses/{code}
|
*/

Route::get('/courses/{code}', function (string $code) {

    $course = DB::table('courses')
        ->where('course_code', $code)
        ->first();

    if (!$course) {
        return response()->json([
            'success' => false,
            'message' => 'Mata kuliah tidak ditemukan.',
        ], 404);
    }

    return response()->json([
        'success' => true,
        'data' => $course,
    ]);

});

/*
|--------------------------------------------------------------------------
| 4. AMBIL CATATAN MATA KULIAH
|--------------------------------------------------------------------------
|
| GET /api/courses/{code}/notes
|
*/

Route::get('/courses/{code}/notes', function (string $code) {

    $course = DB::table('courses')
        ->where('course_code', $code)
        ->first();

    if (!$course) {
        return response()->json([
            'success' => false,
            'message' => 'Mata kuliah tidak ditemukan.',
        ], 404);
    }

    $notes = DB::table('course_notes')
        ->where('course_id', $course->id)
        ->orderByDesc('created_at')
        ->orderByDesc('id')
        ->get();

    return response()->json([
        'success' => true,
        'course_code' => $code,
        'data' => $notes,
    ]);

});

/*
|--------------------------------------------------------------------------
| 5. TAMBAH CATATAN MATA KULIAH
|--------------------------------------------------------------------------
|
| POST /api/courses/{code}/notes
|
*/

Route::post('/courses/{code}/notes', function (
    Request $request,
    string $code
) {

    $course = DB::table('courses')
        ->where('course_code', $code)
        ->first();

    if (!$course) {
        return response()->json([
            'success' => false,
            'message' => 'Mata kuliah tidak ditemukan.',
        ], 404);
    }

    $validator = Validator::make(
        $request->all(),
        [
            'title' => [
                'required',
                'string',
                'max:150',
            ],
            'content' => [
                'required',
                'string',
            ],
        ],
        [
            'title.required' => 'Judul catatan wajib diisi.',
            'title.max' => 'Judul maksimal 150 karakter.',
            'content.required' => 'Isi catatan wajib diisi.',
        ]
    );

    if ($validator->fails()) {
        return response()->json([
            'success' => false,
            'message' => 'Periksa kembali formulir catatan.',
            'errors' => $validator->errors(),
        ], 422);
    }

    $title = trim($request->input('title'));
    $content = trim($request->input('content'));

    if ($title === '' || $content === '') {
        return response()->json([
            'success' => false,
            'message' => 'Judul dan isi catatan wajib diisi.',
        ], 422);
    }

    $now = studyLogNow();

    $id = DB::table('course_notes')->insertGetId([
        'course_id' => $course->id,
        'title' => $title,
        'content' => $content,
        'created_at' => $now,
        'updated_at' => $now,
    ]);

    $note = DB::table('course_notes')
        ->where('id', $id)
        ->first();

    return response()->json([
        'success' => true,
        'message' => 'Catatan berhasil disimpan.',
        'data' => $note,
    ], 201);

});

/*
|--------------------------------------------------------------------------
| 6. HAPUS CATATAN MATA KULIAH
|--------------------------------------------------------------------------
|
| DELETE /api/notes/{id}
|
*/

Route::delete('/notes/{id}', function (int $id) {

    $deleted = DB::table('course_notes')
        ->where('id', $id)
        ->delete();

    if (!$deleted) {
        return response()->json([
            'success' => false,
            'message' => 'Catatan tidak ditemukan.',
        ], 404);
    }

    return response()->json([
        'success' => true,
        'message' => 'Catatan berhasil dihapus.',
    ]);

});

/*
|--------------------------------------------------------------------------
| 7. DAFTAR AKTIVITAS BELAJAR
|--------------------------------------------------------------------------
|
| GET /api/study-logs
|
| Data diurutkan berdasarkan tanggal terbaru.
| Nama mata kuliah diambil langsung dari tabel courses.
|
*/

Route::get('/study-logs', function () {

    $logs = DB::table('study_logs as sl')
        ->join('courses as c', 'sl.course_id', '=', 'c.id')
        ->select(
            'sl.id',
            'sl.course_id',
            'c.course_code',
            'c.course_name',
            'c.class_name',
            'sl.studied_on',
            'sl.duration_minutes',
            'sl.topic',
            'sl.notes',
            'sl.created_at',
            'sl.updated_at'
        )
        ->orderByDesc('sl.studied_on')
        ->orderByDesc('sl.id')
        ->get();

    return response()->json([
        'success' => true,
        'message' => 'Riwayat aktivitas belajar berhasil diambil.',
        'total' => $logs->count(),
        'data' => $logs,
    ]);

});

/*
|--------------------------------------------------------------------------
| 8. STATISTIK AKTIVITAS BELAJAR
|--------------------------------------------------------------------------
|
| GET /api/study-logs/stats
|
| Menghitung:
| - Jumlah seluruh sesi belajar
| - Total durasi belajar
| - Total durasi dalam jam
| - Jumlah sesi minggu ini
| - Total menit belajar minggu ini
| - Jumlah mata kuliah yang pernah dipelajari
|
*/

Route::get('/study-logs/stats', function () {

    $now = studyLogNow();

    $startOfWeek = $now->copy()
        ->startOfWeek(Carbon::MONDAY)
        ->toDateString();

    $endOfWeek = $now->copy()
        ->endOfWeek(Carbon::SUNDAY)
        ->toDateString();

    $all = DB::table('study_logs')
        ->selectRaw('COUNT(*) as total_sessions')
        ->selectRaw(
            'COALESCE(SUM(duration_minutes), 0) as total_minutes'
        )
        ->selectRaw(
            'COUNT(DISTINCT course_id) as total_courses'
        )
        ->first();

    $weekly = DB::table('study_logs')
        ->whereBetween('studied_on', [
            $startOfWeek,
            $endOfWeek,
        ])
        ->selectRaw('COUNT(*) as weekly_sessions')
        ->selectRaw(
            'COALESCE(SUM(duration_minutes), 0) as weekly_minutes'
        )
        ->first();

    $totalMinutes = (int) ($all->total_minutes ?? 0);

    $weeklyMinutes = (int) ($weekly->weekly_minutes ?? 0);

    return response()->json([
        'success' => true,
        'timezone' => 'Asia/Makassar',
        'data' => [
            'total_sessions' => (int) ($all->total_sessions ?? 0),
            'total_minutes' => $totalMinutes,
            'total_hours' => round($totalMinutes / 60, 2),
            'total_courses' => (int) ($all->total_courses ?? 0),

            'weekly_sessions' => (int) ($weekly->weekly_sessions ?? 0),
            'weekly_minutes' => $weeklyMinutes,
            'weekly_hours' => round($weeklyMinutes / 60, 2),

            'week_start' => $startOfWeek,
            'week_end' => $endOfWeek,
        ],
    ]);

});

/*
|--------------------------------------------------------------------------
| 9. TAMBAH AKTIVITAS BELAJAR
|--------------------------------------------------------------------------
|
| POST /api/study-logs
|
| Validasi:
| - Mata kuliah wajib dipilih dan harus tersedia.
| - Tanggal wajib diisi, tidak boleh di masa depan.
| - Durasi minimal 1 menit, maksimal 1440 menit.
| - Materi wajib diisi, maksimal 200 karakter.
| - Catatan tambahan boleh kosong.
|
*/

Route::post('/study-logs', function (Request $request) {

    $validator = Validator::make(
        $request->all(),
        [
            'course_id' => [
                'required',
                'integer',
                'exists:courses,id',
            ],

            'studied_on' => [
                'required',
                'date_format:Y-m-d',
            ],

            'duration_minutes' => [
                'required',
                'integer',
                'min:1',
                'max:1440',
            ],

            'topic' => [
                'required',
                'string',
                'max:200',
            ],

            'notes' => [
                'nullable',
                'string',
            ],
        ],
        [
            'course_id.required' => 'Mata kuliah wajib dipilih.',
            'course_id.exists' => 'Mata kuliah tidak ditemukan.',

            'studied_on.required' => 'Tanggal belajar wajib diisi.',
            'studied_on.date_format' => 'Format tanggal harus YYYY-MM-DD.',

            'duration_minutes.required' => 'Durasi belajar wajib diisi.',
            'duration_minutes.integer' => 'Durasi harus berupa angka.',
            'duration_minutes.min' => 'Durasi minimal 1 menit.',
            'duration_minutes.max' => 'Durasi maksimal 1440 menit.',

            'topic.required' => 'Materi yang dipelajari wajib diisi.',
            'topic.max' => 'Materi maksimal 200 karakter.',
        ]
    );

    if ($validator->fails()) {
        return response()->json([
            'success' => false,
            'message' => 'Data aktivitas belajar tidak valid.',
            'errors' => $validator->errors(),
        ], 422);
    }

    $topic = trim($request->input('topic'));

    if ($topic === '') {
        return response()->json([
            'success' => false,
            'message' => 'Materi yang dipelajari wajib diisi.',
        ], 422);
    }

    $today = studyLogNow()->toDateString();
    $studiedOn = $request->input('studied_on');

    if ($studiedOn > $today) {
        return response()->json([
            'success' => false,
            'message' => 'Tanggal belajar tidak boleh di masa depan.',
        ], 422);
    }

    $notes = $request->input('notes');

    if (is_string($notes)) {
        $notes = trim($notes);

        if ($notes === '') {
            $notes = null;
        }
    }

    $now = studyLogNow();

    $id = DB::table('study_logs')->insertGetId([
        'course_id' => (int) $request->input('course_id'),
        'studied_on' => $studiedOn,
        'duration_minutes' => (int) $request->input('duration_minutes'),
        'topic' => $topic,
        'notes' => $notes,
        'created_at' => $now,
        'updated_at' => $now,
    ]);

    $log = DB::table('study_logs as sl')
        ->join('courses as c', 'sl.course_id', '=', 'c.id')
        ->where('sl.id', $id)
        ->select(
            'sl.id',
            'sl.course_id',
            'c.course_code',
            'c.course_name',
            'sl.studied_on',
            'sl.duration_minutes',
            'sl.topic',
            'sl.notes',
            'sl.created_at',
            'sl.updated_at'
        )
        ->first();

    return response()->json([
        'success' => true,
        'message' => 'Aktivitas belajar berhasil disimpan.',
        'data' => $log,
    ], 201);

});

/*
|--------------------------------------------------------------------------
| 10. HAPUS AKTIVITAS BELAJAR
|--------------------------------------------------------------------------
|
| DELETE /api/study-logs/{id}
|
*/

Route::delete('/study-logs/{id}', function (int $id) {

    $deleted = DB::table('study_logs')
        ->where('id', $id)
        ->delete();

    if (!$deleted) {
        return response()->json([
            'success' => false,
            'message' => 'Aktivitas belajar tidak ditemukan.',
        ], 404);
    }

    return response()->json([
        'success' => true,
        'message' => 'Aktivitas belajar berhasil dihapus.',
    ]);

});


Route::get('/test', function () {
    return response()->json([
        'success' => true,
        'message' => 'Laravel berhasil terhubung ke Flutter!',
    ]);
});
