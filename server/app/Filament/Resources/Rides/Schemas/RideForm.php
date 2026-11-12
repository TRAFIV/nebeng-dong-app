<?php

namespace App\Filament\Resources\Rides\Schemas;

use Closure;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;

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
                        TextInput::make('schedule')
                            ->label('Hari berangkat')
                            ->placeholder('Senin–Jumat')
                            ->required()
                            ->maxLength(50),
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
                            ->required(),
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
                    ->columns(2)
                    ->schema([
                        Textarea::make('route_coordinates')
                            ->label('Koordinat jalur (GeoJSON [lng, lat])')
                            ->helperText('Daftar titik jalan, contoh [[100.3548, -0.9099], [100.4627, -0.9148]]. Minimal 2 titik.')
                            ->rows(4)
                            ->required()
                            ->columnSpanFull()
                            // Kolom disimpan sebagai array; form menampilkannya sebagai teks JSON.
                            ->formatStateUsing(fn ($state) => is_array($state) ? json_encode($state) : $state)
                            ->dehydrateStateUsing(fn (?string $state) => json_decode((string) $state, true))
                            ->rule(fn () => function (string $attribute, mixed $value, Closure $fail): void {
                                if (! self::validCoordinates($value)) {
                                    $fail('Isi daftar minimal 2 titik [lng, lat] dalam format JSON.');
                                }
                            }),
                        TextInput::make('route_distance_m')
                            ->label('Jarak (meter)')
                            ->integer()
                            ->minValue(1)
                            ->required(),
                        TextInput::make('route_duration_s')
                            ->label('Durasi (detik)')
                            ->integer()
                            ->minValue(0)
                            ->required(),
                    ]),
            ]);
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
