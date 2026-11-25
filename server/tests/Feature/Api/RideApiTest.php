<?php

namespace Tests\Feature\Api;

use App\Models\Driver;
use App\Models\Ride;
use Database\Seeders\DemoSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/** Modul 1 — contoh tes endpoint untuk modul lain. */
class RideApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_rides_follow_the_api_contract(): void
    {
        $driver = Driver::factory()->create([
            'name' => 'Taris Rafivdean',
            'phone' => '08123456789',
            'rating' => 4.8,
            'trip_count' => 32,
        ]);
        Ride::factory()->for($driver)->create();

        $response = $this->getJson('/api/v1/rides');

        $response->assertOk()
            ->assertJsonStructure(['data' => [[
                'id',
                'driver' => ['name', 'rating', 'trip_count', 'vehicle_type'],
                'origin' => ['label', 'address', 'lat', 'lng'],
                'destination' => ['label', 'address', 'lat', 'lng'],
                'schedule', 'schedule_days', 'departure_time', 'seat_capacity', 'seats_available', 'fare_per_person',
                'route' => ['distance_m', 'duration_s', 'coordinates'],
            ]]])
            ->assertJsonPath('data.0.driver.name', 'Taris Rafivdean')
            ->assertJsonPath('data.0.driver.rating', 4.8)
            ->assertJsonPath('data.0.origin.lat', -0.9099249)
            ->assertJsonPath('data.0.departure_time', '07.30')
            ->assertJsonPath('data.0.driver.vehicle_type', 'car')
            ->assertJsonPath('data.0.schedule_days', [1, 2, 3, 4, 5])
            ->assertJsonPath('data.0.route.coordinates.0', [100.3548088, -0.9099249]);
        // Data pribadi pengemudi tidak pernah dikirim.
        $this->assertStringNotContainsString('08123456789', $response->getContent());
    }

    public function test_only_active_rides_with_free_seats_are_offered(): void
    {
        $offered = Ride::factory()->create();
        Ride::factory()->full()->create();
        Ride::factory()->inactive()->create();

        $this->getJson('/api/v1/rides')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $offered->id);
    }

    public function test_demo_seeder_matches_the_app_fixtures_and_can_run_twice(): void
    {
        $this->seed(DemoSeeder::class);
        $this->seed(DemoSeeder::class);

        $this->assertSame(4, Ride::count());
        // Tebengan Shiddiq penuh, jadi yang ditawarkan tiga.
        $this->getJson('/api/v1/rides')
            ->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonPath('data.0.driver.name', 'Taris Rafivdean')
            ->assertJsonPath('data.0.schedule', 'Senin–Jumat')
            ->assertJsonPath('data.0.schedule_days', [1, 2, 3, 4, 5]);
    }

    public function test_date_filter_keeps_only_rides_running_that_day(): void
    {
        $weekday = Ride::factory()->create(['schedule_days' => [1, 2, 3, 4, 5]]);
        $weekend = Ride::factory()->create(['schedule_days' => [6, 7]]);
        $unknown = Ride::factory()->create(['schedule' => 'Kalau sempat', 'schedule_days' => null]);

        // 29 November 2026 hari Minggu.
        $this->getJson('/api/v1/rides?date=2026-11-29')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonMissing(['id' => $weekday->id])
            ->assertJsonFragment(['id' => $weekend->id])
            ->assertJsonFragment(['id' => $unknown->id]);
        $this->assertSame('Sabtu, Minggu', $weekend->fresh()->schedule);
    }

    public function test_invalid_date_is_rejected_in_indonesian(): void
    {
        $this->getJson('/api/v1/rides?date=25-11-2026')
            ->assertUnprocessable()
            ->assertJsonPath('errors.date.0', 'Tanggal harus berformat TTTT-BB-HH, contoh 2026-11-25.');
    }
}
