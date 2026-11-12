<?php

namespace Database\Factories;

use App\Models\Driver;
use App\Models\Ride;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<Ride> Rute contoh Khatib Sulaiman → Unand. */
class RideFactory extends Factory
{
    public function definition(): array
    {
        return [
            'driver_id' => Driver::factory(),
            'origin_label' => 'Jl. Khatib Sulaiman',
            'origin_address' => 'Ulak Karang Utara, Padang',
            'origin_lat' => -0.9099249,
            'origin_lng' => 100.3548088,
            'destination_label' => 'Kampus Unand Limau Manis',
            'destination_address' => null,
            'destination_lat' => -0.9148733,
            'destination_lng' => 100.4627099,
            'schedule' => 'Senin–Jumat',
            'departure_time' => '07.30',
            'seat_capacity' => 3,
            'seats_available' => 2,
            'fare_per_person' => 5000,
            'route_coordinates' => [[100.3548088, -0.9099249], [100.4627099, -0.9148733]],
            'route_distance_m' => 16812,
            'route_duration_s' => 1168,
            'is_active' => true,
        ];
    }

    public function full(): static
    {
        return $this->state(['seats_available' => 0]);
    }

    public function inactive(): static
    {
        return $this->state(['is_active' => false]);
    }
}
