<?php

namespace App\Models;

use Database\Factories\DriverFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/** Penyedia tebengan; dikelola admin, bukan akun aplikasi. */
#[Fillable(['name', 'phone', 'vehicle', 'rating', 'trip_count'])]
class Driver extends Model
{
    /** @use HasFactory<DriverFactory> */
    use HasFactory;

    /** @return HasMany<Ride, $this> */
    public function rides(): HasMany
    {
        return $this->hasMany(Ride::class);
    }

    protected function casts(): array
    {
        return [
            'rating' => 'float',
            'trip_count' => 'integer',
        ];
    }
}
