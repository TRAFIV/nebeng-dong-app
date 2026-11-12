<?php

namespace App\Models;

use Database\Factories\RideFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Rute tebengan yang diposting admin atas nama pengemudi (Modul 1). */
#[Fillable([
    'driver_id',
    'origin_label', 'origin_address', 'origin_lat', 'origin_lng',
    'destination_label', 'destination_address', 'destination_lat', 'destination_lng',
    'schedule', 'departure_time', 'seat_capacity', 'seats_available', 'fare_per_person',
    'route_coordinates', 'route_distance_m', 'route_duration_s', 'is_active',
])]
class Ride extends Model
{
    /** @use HasFactory<RideFactory> */
    use HasFactory;

    /** @return BelongsTo<Driver, $this> */
    public function driver(): BelongsTo
    {
        return $this->belongsTo(Driver::class);
    }

    /** Rute yang ditawarkan ke penumpang: aktif dan masih ada kursi. */
    public function scopeOffered(Builder $query): void
    {
        $query->where('is_active', true)->where('seats_available', '>', 0);
    }

    protected function casts(): array
    {
        return [
            'origin_lat' => 'float',
            'origin_lng' => 'float',
            'destination_lat' => 'float',
            'destination_lng' => 'float',
            'seat_capacity' => 'integer',
            'seats_available' => 'integer',
            'fare_per_person' => 'integer',
            'route_coordinates' => 'array',
            'route_distance_m' => 'integer',
            'route_duration_s' => 'integer',
            'is_active' => 'boolean',
        ];
    }
}
