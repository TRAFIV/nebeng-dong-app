<?php

namespace App\Filament\Resources\Rides\Pages;

use App\Filament\Resources\Rides\RideResource;
use App\Filament\Resources\Rides\Schemas\RideForm;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditRide extends EditRecord
{
    protected static string $resource = RideResource::class;

    /** Jalur dikosongkan admin dihitung ulang dari asal dan tujuan. */
    protected function mutateFormDataBeforeSave(array $data): array
    {
        return RideForm::withRoute($data) ?? $this->halt();
    }

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
