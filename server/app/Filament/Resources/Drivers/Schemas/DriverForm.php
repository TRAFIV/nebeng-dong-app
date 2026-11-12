<?php

namespace App\Filament\Resources\Drivers\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class DriverForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(2)
            ->components([
                TextInput::make('name')
                    ->label('Nama')
                    ->required()
                    ->maxLength(255),
                TextInput::make('phone')
                    ->label('No. HP (hanya untuk admin)')
                    ->tel()
                    ->maxLength(30),
                TextInput::make('vehicle')
                    ->label('Kendaraan')
                    ->placeholder('Motor / Mobil, plat nomor')
                    ->maxLength(255),
                TextInput::make('rating')
                    ->label('Rating')
                    ->numeric()
                    ->minValue(0)
                    ->maxValue(5)
                    ->step(0.1)
                    ->default(0)
                    ->helperText('Nanti diperbarui otomatis oleh modul Rating.'),
                TextInput::make('trip_count')
                    ->label('Jumlah perjalanan')
                    ->integer()
                    ->minValue(0)
                    ->default(0),
            ]);
    }
}
