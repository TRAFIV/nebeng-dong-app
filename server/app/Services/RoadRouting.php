<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use RuntimeException;

/**
 * Menghitung jalur jalan mobil dari asal ke tujuan lewat OSRM (layanan rute
 * yang sama dengan aplikasi). Hanya menghitung; tidak ada data aplikasi yang
 * disimpan di layanan itu.
 */
class RoadRouting
{
    /**
     * @return array{coordinates: list<array{0: float, 1: float}>, distance_m: int, duration_s: int}
     *
     * @throws RuntimeException pesan Bahasa Indonesia untuk admin.
     */
    public function between(float $fromLat, float $fromLng, float $toLat, float $toLng): array
    {
        $url = rtrim((string) config('services.routing.url'), '/')
            ."/route/v1/driving/{$fromLng},{$fromLat};{$toLng},{$toLat}";

        try {
            $response = Http::withHeaders(['User-Agent' => config('services.routing.user_agent')])
                ->timeout(15)
                ->get($url, ['overview' => 'full', 'geometries' => 'geojson', 'steps' => 'false']);
        } catch (ConnectionException) {
            throw new RuntimeException('Layanan rute tidak bisa dihubungi. Coba lagi sebentar.');
        }

        $route = $response->json('routes.0');
        $coordinates = $route['geometry']['coordinates'] ?? null;
        if (! $response->ok() || $response->json('code') !== 'Ok'
            || ! is_array($coordinates) || count($coordinates) < 2) {
            throw new RuntimeException('Jalur jalan tidak ditemukan. Periksa koordinat asal dan tujuan.');
        }

        foreach ($response->json('waypoints', []) as $waypoint) {
            if (($waypoint['distance'] ?? 0) > 1000) {
                throw new RuntimeException('Asal atau tujuan terlalu jauh dari jalan (lebih dari 1 km).');
            }
        }

        return [
            'coordinates' => array_map(
                fn (array $point) => [round((float) $point[0], 6), round((float) $point[1], 6)],
                $coordinates,
            ),
            'distance_m' => (int) round($route['distance']),
            'duration_s' => (int) round($route['duration']),
        ];
    }
}
