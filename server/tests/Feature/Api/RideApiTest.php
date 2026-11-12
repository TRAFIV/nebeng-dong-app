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
                'driver' => ['name', 'rating', 'trip_count'],
                'origin' => ['label', 'address', 'lat', 'lng'],
                'destination' => ['label', 'address', 'lat', 'lng'],
                'schedule', 'departure_time', 'seat_capacity', 'seats_available', 'fare_per_person',
                'route' => ['distance_m', 'duration_s', 'coordinates'],
            ]]])
            ->assertJsonPath('data.0.driver.name', 'Taris Rafivdean')
            ->assertJsonPath('data.0.driver.rating', 4.8)
            ->assertJsonPath('data.0.origin.lat', -0.9099249)
            ->assertJsonPath('data.0.departure_time', '07.30')
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
            ->assertJsonPath('data.0.schedule', 'Senin–Jumat');
    }
}
