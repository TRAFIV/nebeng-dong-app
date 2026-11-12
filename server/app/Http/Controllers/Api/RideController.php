<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\RideResource;
use App\Models\Ride;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

/**
 * Modul 1 (Mikail) — contoh acuan endpoint untuk modul lain.
 * Kontrak: docs/api/kontrak-api.md bagian 3.
 */
class RideController extends Controller
{
    /**
     * GET /api/v1/rides — rute aktif yang masih punya kursi.
     * Pencocokan "searah" dihitung aplikasi, jadi semua jalur dikirim.
     */
    public function index(): AnonymousResourceCollection
    {
        $rides = Ride::query()
            ->offered()
            ->with('driver')
            ->orderBy('departure_time')
            ->get();

        return RideResource::collection($rides);
    }
}
