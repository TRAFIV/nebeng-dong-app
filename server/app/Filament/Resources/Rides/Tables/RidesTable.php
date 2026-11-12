<?php

namespace App\Filament\Resources\Rides\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class RidesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('driver.name')
                    ->label('Pengemudi')
                    ->searchable(),
                TextColumn::make('origin_label')
                    ->label('Asal')
                    ->searchable(),
                TextColumn::make('destination_label')
                    ->label('Tujuan')
                    ->searchable(),
                TextColumn::make('schedule')
                    ->label('Hari'),
                TextColumn::make('departure_time')
                    ->label('Jam')
                    ->sortable(),
                TextColumn::make('seats_available')
                    ->label('Sisa kursi')
                    ->formatStateUsing(fn ($state, $record) => "{$state}/{$record->seat_capacity}")
                    ->sortable(),
                TextColumn::make('fare_per_person')
                    ->label('Ongkos')
                    ->formatStateUsing(fn (int $state) => $state === 0
                        ? 'Belum diatur'
                        : 'Rp'.number_format($state, 0, ',', '.'))
                    ->sortable(),
                IconColumn::make('is_active')
                    ->label('Tampil')
                    ->boolean(),
                TextColumn::make('updated_at')
                    ->label('Diubah')
                    ->dateTime('d M Y H.i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('departure_time')
            ->filters([
                TernaryFilter::make('is_active')->label('Tampil di aplikasi'),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
