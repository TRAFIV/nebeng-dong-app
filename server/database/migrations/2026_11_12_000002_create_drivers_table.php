<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Pengemudi adalah data penyedia tebengan yang dikelola admin, bukan akun
 * aplikasi (aplikasi mobile hanya role penumpang).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('drivers', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            // Data pribadi: hanya untuk admin, tidak pernah dikirim ke aplikasi.
            $table->string('phone', 30)->nullable();
            $table->string('vehicle')->nullable();
            // Nilai publik; nanti diperbarui modul Rating dari penilaian penumpang.
            $table->decimal('rating', 2, 1)->default(0);
            $table->unsignedInteger('trip_count')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('drivers');
    }
};
