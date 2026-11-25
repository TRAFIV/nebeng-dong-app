<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\RideResource;
use App\Models\Ride;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Carbon;

/**
 * Modul 1 (Mikail) — contoh acuan endpoint untuk modul lain.
 * Kontrak: docs/api/kontrak-api.md bagian 3.
 */
class RideController extends Controller
{
    /**
     * GET /api/v1/rides[?date=YYYY-MM-DD] — rute aktif yang masih punya kursi,
     * opsional hanya yang jalan pada tanggal itu. Pencocokan "searah" dihitung
     * aplikasi, jadi semua jalur dikirim. Sisa kursi belum per tanggal
     * (menunggu tabel pesanan).
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $validated = $request->validate(
            ['date' => ['nullable', 'date_format:Y-m-d']],
            ['date.date_format' => 'Tanggal harus berformat TTTT-BB-HH, contoh 2026-11-25.'],
        );

        $rides = Ride::query()
            ->offered()
            ->when(
                $validated['date'] ?? null,
                fn ($query, string $date) => $query->runsOn(Carbon::createFromFormat('Y-m-d', $date)),
            )
            ->with('driver')
            ->orderBy('departure_time')
            ->get();

        return RideResource::collection($rides);
    }
}
