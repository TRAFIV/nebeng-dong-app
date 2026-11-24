<?php

namespace App\Filament\Resources\Rides\Schemas;

use App\Models\Driver;
use App\Services\RoadRouting;
use App\Support\Schedule;
use Closure;
use Filament\Actions\Action;
use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Notifications\Notification;
use Filament\Schemas\Components\Actions;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Components\Utilities\Set;
use Filament\Schemas\Schema;
use RuntimeException;

/** Form "Posting Rute" admin atas nama pengemudi (Modul 1). */
class RideForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Pengemudi dan jadwal')
                    ->columns(2)
                    ->schema([
                        Select::make('driver_id')
                            ->label('Pengemudi')
                            ->relationship('driver', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),
                        CheckboxList::make('schedule_days')
                            ->label('Hari jalan')
                            ->options(Schedule::DAYS)
                            ->default([1, 2, 3, 4, 5])
                            ->columns(4)
                            ->columnSpanFull()
                            ->required()
                            ->validationMessages(['required' => 'Pilih minimal satu hari.']),
                        TextInput::make('departure_time')
                            ->label('Jam cabut (HH.mm)')
                            ->placeholder('07.30')
                            ->required()
                            ->regex('/^([01]\d|2[0-3])\.[0-5]\d$/')
                            ->validationMessages(['regex' => 'Tulis jam seperti 07.30.']),
                        Toggle::make('is_active')
                            ->label('Tampil di aplikasi')
                            ->default(true),
                    ]),
                Section::make('Kursi dan ongkos')
                    ->columns(3)
                    ->schema([
                        TextInput::make('seat_capacity')
                            ->label('Kapasitas kursi')
                            ->integer()
                            ->minValue(1)
                            ->maxValue(8)
                            ->required()
                            ->rule(fn (Get $get) => function (string $attribute, mixed $value, Closure $fail) use ($get): void {
                                $driver = Driver::find($get('driver_id'));
                                if ($driver?->vehicle_type === Driver::VEHICLE_MOTOR && (int) $value > 1) {
                                    $fail('Motor hanya muat 1 penumpang.');
                                }
                            }),
                        TextInput::make('seats_available')
                            ->label('Sisa kursi')
                            ->integer()
                            ->minValue(0)
                            ->required()
                            ->lte('seat_capacity')
                            ->validationMessages(['lte' => 'Sisa kursi tidak boleh melebihi kapasitas.']),
                        TextInput::make('fare_per_person')
                            ->label('Ongkos per orang')
                            ->prefix('Rp')
                            ->integer()
                            ->minValue(0)
                            ->default(0)
                            ->helperText('0 berarti ongkos belum diatur, bukan gratis.'),
                    ]),
                Section::make('Asal')
                    ->columns(2)
                    ->schema(self::place('origin')),
                Section::make('Tujuan')
                    ->columns(2)
                    ->schema(self::place('destination')),
                Section::make('Jalur jalan')
                    ->description('Kosongkan untuk dihitung otomatis dari asal dan tujuan saat disimpan, atau tekan "Hitung jalur otomatis" untuk melihatnya dulu.')
                    ->columns(2)
                    ->schema([
                        Actions::make([
                            Action::make('hitungJalur')
                                ->label('Hitung jalur otomatis')
                                ->icon('heroicon-o-map')
                                ->action(function (Get $get, Set $set): void {
                                    try {
                                        $route = self::routeFrom($get);
                                    } catch (RuntimeException $error) {
                                        Notification::make()->title($error->getMessage())->danger()->send();

                                        return;
                                    }
                                    $set('route_coordinates', json_encode($route['coordinates']));
                                    $set('route_distance_m', $route['distance_m']);
                                    $set('route_duration_s', $route['duration_s']);
                                    Notification::make()
                                        ->title('Jalur dihitung: '.number_format($route['distance_m'] / 1000, 1, ',', '.').' km')
                                        ->success()
                                        ->send();
                                }),
                        ])->columnSpanFull(),
                        Textarea::make('route_coordinates')
                            ->label('Koordinat jalur (GeoJSON [lng, lat])')
                            ->helperText('Terisi otomatis. Isi manual hanya bila perlu: contoh [[100.3548, -0.9099], [100.4627, -0.9148]].')
                            ->rows(4)
                            ->columnSpanFull()
                            // Kolom disimpan sebagai array; form menampilkannya sebagai teks JSON.
                            ->formatStateUsing(fn ($state) => is_array($state) ? json_encode($state) : $state)
                            ->dehydrateStateUsing(fn (?string $state) => json_decode((string) $state, true))
                            ->rule(fn () => function (string $attribute, mixed $value, Closure $fail): void {
                                if (filled($value) && ! self::validCoordinates($value)) {
                                    $fail('Isi daftar minimal 2 titik [lng, lat] dalam format JSON.');
                                }
                            }),
                        TextInput::make('route_distance_m')
                            ->label('Jarak (meter)')
                            ->integer()
                            ->minValue(1),
                        TextInput::make('route_duration_s')
                            ->label('Durasi (detik)')
                            ->integer()
                            ->minValue(0),
                    ]),
            ]);
    }

    /**
     * Jalur dari koordinat asal/tujuan di form.
     *
     * @return array{coordinates: list<array{0: float, 1: float}>, distance_m: int, duration_s: int}
     *
     * @throws RuntimeException
     */
    public static function routeFrom(Get|array $data): array
    {
        $value = fn (string $key) => is_array($data) ? ($data[$key] ?? null) : $data($key);
        foreach (['origin_lat', 'origin_lng', 'destination_lat', 'destination_lng'] as $key) {
            if (! is_numeric($value($key))) {
                throw new RuntimeException('Isi lintang dan bujur asal serta tujuan dulu.');
            }
        }

        return app(RoadRouting::class)->between(
            (float) $value('origin_lat'),
            (float) $value('origin_lng'),
            (float) $value('destination_lat'),
            (float) $value('destination_lng'),
        );
    }

    /**
     * Dipanggil halaman Buat/Ubah sebelum menyimpan: jalur kosong dihitung
     * otomatis. Gagal = notifikasi dan penyimpanan dibatalkan.
     */
    public static function withRoute(array $data): ?array
    {
        if (filled($data['route_coordinates'] ?? null)
            && filled($data['route_distance_m'] ?? null)
            && filled($data['route_duration_s'] ?? null)) {
            return $data;
        }
        try {
            $route = self::routeFrom($data);
        } catch (RuntimeException $error) {
            Notification::make()
                ->title('Jalur belum bisa dihitung')
                ->body($error->getMessage())
                ->danger()
                ->send();

            return null;
        }

        return [
            ...$data,
            'route_coordinates' => $route['coordinates'],
            'route_distance_m' => $route['distance_m'],
            'route_duration_s' => $route['duration_s'],
        ];
    }

    /** Kolom label, alamat dan koordinat untuk asal atau tujuan. */
    private static function place(string $prefix): array
    {
        return [
            TextInput::make("{$prefix}_label")
                ->label('Nama tempat')
                ->required()
                ->maxLength(255),
            TextInput::make("{$prefix}_address")
                ->label('Alamat')
                ->maxLength(255),
            TextInput::make("{$prefix}_lat")
                ->label('Lintang (lat)')
                ->numeric()
                ->minValue(-90)
                ->maxValue(90)
                ->required(),
            TextInput::make("{$prefix}_lng")
                ->label('Bujur (lng)')
                ->numeric()
                ->minValue(-180)
                ->maxValue(180)
                ->required(),
        ];
    }

    public static function validCoordinates(mixed $value): bool
    {
        $points = is_string($value) ? json_decode($value, true) : $value;
        if (! is_array($points) || count($points) < 2) {
            return false;
        }
        foreach ($points as $point) {
            if (! is_array($point) || count($point) !== 2
                || ! is_numeric($point[0]) || ! is_numeric($point[1])
                || abs($point[0]) > 180 || abs($point[1]) > 90) {
                return false;
            }
        }

        return true;
    }
}
