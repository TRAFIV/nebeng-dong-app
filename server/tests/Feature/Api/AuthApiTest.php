<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    private function passenger(): User
    {
        return User::factory()->create([
            'email' => 'mikail@student.unand.ac.id',
            'password' => 'rahasia123',
        ]);
    }

    public function test_login_returns_a_token_that_opens_me(): void
    {
        $this->passenger();

        $login = $this->postJson('/api/v1/auth/login', [
            'email' => 'mikail@student.unand.ac.id',
            'password' => 'rahasia123',
        ]);

        $login->assertOk()
            ->assertJsonPath('data.user.email', 'mikail@student.unand.ac.id')
            ->assertJsonPath('data.user.role', User::ROLE_PASSENGER)
            ->assertJsonMissingPath('data.user.password');
        $token = $login->json('data.token');

        $this->withToken($token)->getJson('/api/v1/me')
            ->assertOk()
            ->assertJsonPath('data.email', 'mikail@student.unand.ac.id');
    }

    public function test_wrong_password_uses_the_contract_error_format(): void
    {
        $this->passenger();

        $this->postJson('/api/v1/auth/login', [
            'email' => 'mikail@student.unand.ac.id',
            'password' => 'salah',
        ])
            ->assertStatus(422)
            ->assertExactJson([
                'message' => 'Email atau kata sandi salah.',
                'errors' => ['email' => ['Email atau kata sandi salah.']],
            ]);

        $this->postJson('/api/v1/auth/login', [])
            ->assertStatus(422)
            ->assertJsonPath('errors.email.0', 'Email wajib diisi.')
            ->assertJsonPath('errors.password.0', 'Kata sandi wajib diisi.');
    }

    public function test_protected_routes_answer_401_and_404_in_indonesian(): void
    {
        $this->getJson('/api/v1/me')
            ->assertStatus(401)
            ->assertExactJson(['message' => 'Sesi kamu berakhir. Silakan masuk lagi.']);

        // Klien yang tidak mengirim header Accept JSON tetap dijawab 401, bukan dialihkan.
        $this->get('/api/v1/me')
            ->assertStatus(401)
            ->assertExactJson(['message' => 'Sesi kamu berakhir. Silakan masuk lagi.']);

        $this->getJson('/api/v1/tidak-ada')
            ->assertStatus(404)
            ->assertExactJson(['message' => 'Data tidak ditemukan.']);
    }

    public function test_logout_revokes_the_token(): void
    {
        $user = $this->passenger();
        $token = $user->createToken('mobile')->plainTextToken;

        $this->withToken($token)->postJson('/api/v1/auth/logout')->assertNoContent();

        $this->assertSame(0, $user->tokens()->count());
    }
}
