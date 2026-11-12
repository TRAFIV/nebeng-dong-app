<?php

use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Tamu di API dijawab 401 JSON (lihat render di bawah), bukan diarahkan
        // ke halaman login; tamu di halaman web diarahkan ke login panel admin.
        $middleware->redirectGuestsTo(
            fn (Request $request) => $request->is('api/*') ? null : '/admin/login',
        );
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $isApi = fn (Request $request) => $request->is('api/*') || $request->expectsJson();
        $exceptions->shouldRenderJsonWhen($isApi);

        // Format error API: {"message": "...", "errors": {...}} dengan pesan
        // Bahasa Indonesia, karena aplikasi menampilkan "message" apa adanya.
        $exceptions->render(fn (AuthenticationException $e, Request $request) => $isApi($request)
            ? response()->json(['message' => 'Sesi kamu berakhir. Silakan masuk lagi.'], 401)
            : null);

        $exceptions->render(fn (AuthorizationException|AccessDeniedHttpException $e, Request $request) => $isApi($request)
            ? response()->json(['message' => 'Kamu tidak punya akses ke data ini.'], 403)
            : null);

        $exceptions->render(fn (NotFoundHttpException $e, Request $request) => $isApi($request)
            ? response()->json(['message' => 'Data tidak ditemukan.'], 404)
            : null);

        $exceptions->render(fn (ValidationException $e, Request $request) => $isApi($request)
            ? response()->json([
                'message' => collect($e->errors())->flatten()->first() ?? 'Periksa kembali isianmu.',
                'errors' => $e->errors(),
            ], $e->status)
            : null);
    })->create();
