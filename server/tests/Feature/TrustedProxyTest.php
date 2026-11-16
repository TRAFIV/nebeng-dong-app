<?php

namespace Tests\Feature;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Tests\TestCase;

/**
 * Di VPS, nginx/Caddy menerima HTTPS lalu meneruskan ke container lewat http.
 * Laravel harus membaca X-Forwarded-* agar tautan yang dibuatnya tetap https.
 */
class TrustedProxyTest extends TestCase
{
    public function test_request_behind_https_proxy_builds_https_urls(): void
    {
        Route::get('/_proxy-check', fn (Request $request) => [
            'secure' => $request->secure(),
            'url' => url('/admin'),
        ]);

        $this->withHeaders([
            'X-Forwarded-Proto' => 'https',
            'X-Forwarded-Host' => 'api.contoh.test',
            'X-Forwarded-Port' => '443',
        ])->getJson('/_proxy-check')
            ->assertOk()
            ->assertExactJson([
                'secure' => true,
                'url' => 'https://api.contoh.test/admin',
            ]);
    }
}
