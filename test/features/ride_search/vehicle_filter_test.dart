import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_filter_view_model.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/models/vehicle_kind.dart';

Ride _motor() {
  final base = demoRides.first;
  return Ride(
    id: 'motor-1',
    driverName: 'Pengemudi motor',
    driverRating: 4.5,
    driverTripCount: 3,
    origin: base.origin,
    destination: base.destination,
    schedule: base.schedule,
    departureTime: base.departureTime,
    seatCapacity: 1,
    seatsAvailable: 1,
    farePerPerson: 4000,
    geography: base.geography,
  );
}

void main() {
  test('Filter kendaraan memisahkan mobil dan motor', () {
    final car = demoRides.first;
    final motor = _motor();
    expect(car.vehicle, VehicleKind.car);
    expect(motor.vehicle, VehicleKind.motor);
    const motorOnly = RideFilter(vehicle: VehicleKind.motor);
    expect(motorOnly.isActive, isTrue);
    expect(motorOnly.matches(motor), isTrue);
    expect(motorOnly.matches(car), isFalse);
    expect(const RideFilter(vehicle: VehicleKind.car).matches(motor), isFalse);
    expect(const RideFilter().matches(motor), isTrue);
  });

  test('Memilih motor mengunci minimal kursi di 1; atur ulang semua', () {
    final vm = RideFilterViewModel(
      initialFilter: const RideFilter(minimumSeats: 3),
    );
    addTearDown(vm.dispose);
    vm.selectVehicle(VehicleKind.motor);
    expect(vm.seats, 1);
    expect(vm.canSelectSeats(2), isFalse);
    vm.selectSeats(2);
    expect(vm.seats, 1);
    expect(vm.apply('')!.vehicle, VehicleKind.motor);
    vm.reset();
    expect(vm.vehicle, isNull);
    expect(vm.canSelectSeats(3), isTrue);
  });
}
