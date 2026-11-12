<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Rute tebengan yang diposting admin atas nama pengemudi (Modul 1).
 * Bentuk JSON-nya: docs/api/kontrak-api.md bagian 3.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rides', function (Blueprint $table) {
            $table->id();
            $table->foreignId('driver_id')->constrained()->cascadeOnDelete();

            $table->string('origin_label');
            $table->string('origin_address')->nullable();
            $table->decimal('origin_lat', 10, 7);
            $table->decimal('origin_lng', 10, 7);
            $table->string('destination_label');
            $table->string('destination_address')->nullable();
            $table->decimal('destination_lat', 10, 7);
            $table->decimal('destination_lng', 10, 7);

            $table->string('schedule', 50);
            $table->string('departure_time', 5); // HH.mm
            $table->unsignedTinyInteger('seat_capacity');
            $table->unsignedTinyInteger('seats_available');
            // Rupiah bulat; 0 berarti ongkos belum diatur, bukan gratis.
            $table->unsignedInteger('fare_per_person')->default(0);

            // Garis jalan GeoJSON: [[lng, lat], ...].
            $table->json('route_coordinates');
            $table->unsignedInteger('route_distance_m');
            $table->unsignedInteger('route_duration_s');

            // Rute nonaktif tidak tampil di aplikasi tanpa harus dihapus.
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rides');
    }
};
