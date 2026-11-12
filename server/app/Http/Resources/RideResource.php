<?php

namespace App\Http\Resources;

use App\Models\Ride;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Bentuk JSON satu rute, persis docs/api/kontrak-api.md bagian 3.
 * Dibaca aplikasi oleh lib/features/ride_search/data/ride_json.dart.
 *
 * @mixin Ride
 */
class RideResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            // Profil publik saja; nomor HP pengemudi tidak dikirim.
            'driver' => [
                'name' => $this->driver->name,
                'rating' => $this->driver->rating,
                'trip_count' => $this->driver->trip_count,
            ],
            'origin' => [
                'label' => $this->origin_label,
                'address' => $this->origin_address,
                'lat' => $this->origin_lat,
                'lng' => $this->origin_lng,
            ],
            'destination' => [
                'label' => $this->destination_label,
                'address' => $this->destination_address,
                'lat' => $this->destination_lat,
                'lng' => $this->destination_lng,
            ],
            'schedule' => $this->schedule,
            'departure_time' => $this->departure_time,
            'seat_capacity' => $this->seat_capacity,
            'seats_available' => $this->seats_available,
            'fare_per_person' => $this->fare_per_person,
            'route' => [
                'distance_m' => $this->route_distance_m,
                'duration_s' => $this->route_duration_s,
                'coordinates' => $this->route_coordinates,
            ],
        ];
    }
}
