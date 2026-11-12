<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\RideController;
use Illuminate\Support\Facades\Route;

/*
| REST API Nebeng Dong — semua alamat diawali /api/v1.
| Kontrak lengkap: docs/api/kontrak-api.md (di root repo).
|
| Cara menambah endpoint modul: lihat server/README.md bagian
| "Menambah endpoint modulmu", dan contoh RideController.
*/

Route::prefix('v1')->group(function () {
    // Akun (dasar; dilanjutkan pemilik modul Akun)
    Route::post('auth/login', [AuthController::class, 'login']);

    // Rute — Modul 1 (Mikail). Data publik, boleh dibaca sebelum masuk.
    Route::get('rides', [RideController::class, 'index']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);

        // Pesanan — Modul 2 (Taris): /bookings
        // Ongkos  — Modul 3 (Shiddiq): /cost-shares
        // Rating  — Modul 4 (Duha): /trips
    });
});
