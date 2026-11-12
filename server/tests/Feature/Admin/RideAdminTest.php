<?php

namespace Tests\Feature\Admin;

use App\Filament\Resources\Rides\Pages\CreateRide;
use App\Models\Driver;
use App\Models\Ride;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

/** Admin memposting rute atas nama pengemudi (pemicu Modul 1). */
class RideAdminTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): User
    {
        return User::factory()->create(['role' => User::ROLE_ADMIN]);
    }

    /** Isian form yang benar; tiap tes mengubah sebagian. */
    private function validForm(Driver $driver): array
    {
        return [
            'driver_id' => $driver->id,
            'schedule' => 'Senin–Jumat',
            'departure_time' => '07.30',
            'is_active' => true,
            'seat_capacity' => 3,
            'seats_available' => 2,
            'fare_per_person' => 5000,
            'origin_label' => 'Jl. Khatib Sulaiman',
            'origin_address' => 'Padang',
            'origin_lat' => -0.9099249,
            'origin_lng' => 100.3548088,
            'destination_label' => 'Kampus Unand Limau Manis',
            'destination_address' => null,
            'destination_lat' => -0.9148733,
            'destination_lng' => 100.4627099,
            'route_coordinates' => '[[100.3548088, -0.9099249], [100.4627099, -0.9148733]]',
            'route_distance_m' => 16812,
            'route_duration_s' => 1168,
        ];
    }

    public function test_only_admins_can_open_the_panel(): void
    {
        $this->actingAs($this->admin())->get('/admin/rides')->assertOk();
        $this->actingAs(User::factory()->create())->get('/admin/rides')->assertForbidden();
    }

    public function test_admin_posts_a_ride_that_the_app_receives(): void
    {
        $this->actingAs($this->admin());
        $driver = Driver::factory()->create(['name' => 'Taris Rafivdean']);

        Livewire::test(CreateRide::class)
            ->fillForm($this->validForm($driver))
            ->call('create')
            ->assertHasNoFormErrors();

        $ride = Ride::sole();
        $this->assertSame([[100.3548088, -0.9099249], [100.4627099, -0.9148733]], $ride->route_coordinates);
        $this->getJson('/api/v1/rides')
            ->assertJsonPath('data.0.driver.name', 'Taris Rafivdean')
            ->assertJsonPath('data.0.departure_time', '07.30');
    }

    public function test_form_rejects_invalid_time_seats_and_route(): void
    {
        $this->actingAs($this->admin());
        $form = $this->validForm(Driver::factory()->create());

        Livewire::test(CreateRide::class)
            ->fillForm([
                ...$form,
                'departure_time' => '7:30',
                'seats_available' => 5,
                'route_coordinates' => '[[100.35, -0.90]]',
            ])
            ->call('create')
            ->assertHasFormErrors(['departure_time', 'seats_available', 'route_coordinates']);

        $this->assertSame(0, Ride::count());
    }
}
