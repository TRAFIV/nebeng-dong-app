<?php

use App\Support\Schedule;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Menyesuaikan dengan aplikasi (desain "Garis & Titik", 24 November 2026):
 * - pengemudi punya jenis kendaraan (mobil/motor) untuk filter dan gambar;
 * - rute punya daftar hari jalan agar penumpang bisa mencari per tanggal.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('drivers', function (Blueprint $table) {
            // car = mobil, motor = motor (hanya satu penumpang).
            $table->string('vehicle_type', 10)->default('car')->after('phone');
        });

        Schema::table('rides', function (Blueprint $table) {
            // Hari jalan ISO: 1 = Senin … 7 = Minggu. Null = tidak diketahui.
            $table->json('schedule_days')->nullable()->after('schedule');
        });

        // Isi dari teks jadwal yang sudah ada, mis. "Senin–Jumat" → [1..5].
        foreach (DB::table('rides')->select('id', 'schedule')->get() as $ride) {
            $days = Schedule::parse((string) $ride->schedule);
            DB::table('rides')->where('id', $ride->id)->update([
                'schedule_days' => $days === null ? null : json_encode($days),
            ]);
        }
    }

    public function down(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->dropColumn('schedule_days');
        });
        Schema::table('drivers', function (Blueprint $table) {
            $table->dropColumn('vehicle_type');
        });
    }
};
