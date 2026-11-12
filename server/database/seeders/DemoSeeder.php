<?php

namespace Database\Seeders;

use App\Models\Driver;
use App\Models\Ride;
use App\Models\User;
use Illuminate\Database\Seeder;

/**
 * Data latihan yang sama dengan aplikasi (lib/features/ride_search/data/fixtures),
 * supaya hasil pencarian sama baik dari server maupun lokal.
 * Bisa dijalankan ulang tanpa membuat data ganda.
 */
class DemoSeeder extends Seeder
{
    public function run(): void
    {
        // Akun penumpang contoh untuk mencoba login dari aplikasi.
        User::updateOrCreate(
            ['email' => 'mikail@student.unand.ac.id'],
            ['name' => 'Mikail', 'password' => 'nebengdong', 'role' => User::ROLE_PASSENGER],
        );

        $rides = json_decode(
            file_get_contents(database_path('seeders/data/demo_rides.json')),
            true,
            flags: JSON_THROW_ON_ERROR,
        );

        foreach ($rides as $data) {
            $driver = Driver::updateOrCreate(
                ['name' => $data['driver']['name']],
                ['rating' => $data['driver']['rating'], 'trip_count' => $data['driver']['trip_count']],
            );

            Ride::updateOrCreate(
                [
                    'driver_id' => $driver->id,
                    'origin_label' => $data['origin']['label'],
                    'destination_label' => $data['destination']['label'],
                    'departure_time' => $data['departure_time'],
                ],
                [
                    'origin_address' => $data['origin']['address'],
                    'origin_lat' => $data['origin']['lat'],
                    'origin_lng' => $data['origin']['lng'],
                    'destination_address' => $data['destination']['address'],
                    'destination_lat' => $data['destination']['lat'],
                    'destination_lng' => $data['destination']['lng'],
                    'schedule' => $data['schedule'],
                    'seat_capacity' => $data['seat_capacity'],
                    'seats_available' => $data['seats_available'],
                    'fare_per_person' => $data['fare_per_person'],
                    'route_coordinates' => $data['route']['coordinates'],
                    'route_distance_m' => $data['route']['distance_m'],
                    'route_duration_s' => $data['route']['duration_s'],
                    'is_active' => true,
                ],
            );
        }
    }
}
