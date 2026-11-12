<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Akun admin pertama dari ADMIN_EMAIL/ADMIN_PASSWORD di .env.
     * Di luar production juga diisi data demo (DemoSeeder).
     */
    public function run(): void
    {
        $password = env('ADMIN_PASSWORD');
        if (blank($password)) {
            $password = Str::password(16);
            $this->command?->warn("ADMIN_PASSWORD kosong; kata sandi admin sementara: {$password}");
        }

        User::updateOrCreate(
            ['email' => env('ADMIN_EMAIL', 'admin@nebengdong.test')],
            ['name' => 'Admin Nebeng Dong', 'password' => $password, 'role' => User::ROLE_ADMIN],
        );

        if (! app()->isProduction()) {
            $this->call(DemoSeeder::class);
        }
    }
}
