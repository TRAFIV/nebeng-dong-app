<?php

namespace App\Filament\Resources\Rides\Pages;

use App\Filament\Resources\Rides\RideResource;
use App\Filament\Resources\Rides\Schemas\RideForm;
use Filament\Resources\Pages\CreateRecord;

class CreateRide extends CreateRecord
{
    protected static string $resource = RideResource::class;

    /** Jalur kosong dihitung otomatis dari asal dan tujuan. */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        return RideForm::withRoute($data) ?? $this->halt();
    }
}
