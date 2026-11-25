import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:praktikum_mobile/core/di/api_client_scope.dart';
import 'package:praktikum_mobile/core/di/ride_repository_scope.dart';
import 'package:praktikum_mobile/core/network/api_client.dart';
import 'package:praktikum_mobile/core/network/api_exception.dart';
import 'package:praktikum_mobile/core/network/token_store.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/remote_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';

/// Contoh satu tebengan sesuai `docs/api/kontrak-api.md`.
const rideJson = {
  'id': 7,
  'driver': {'name': 'Taris Rafivdean', 'rating': 4.8, 'trip_count': 32},
  'origin': {
    'label': 'Jl. Khatib Sulaiman',
    'address': 'Ulak Karang Utara, Padang',
    'lat': -0.9099249,
    'lng': 100.3548088,
  },
  'destination': {
    'label': 'Kampus Unand Limau Manis',
    'lat': -0.9148733,
    'lng': 100.4627099,
  },
  'schedule': 'Senin–Jumat',
  'departure_time': '07.30',
  'seat_capacity': 3,
  'seats_available': 2,
  'fare_per_person': 5000,
  'route': {
    'distance_m': 13400,
    'duration_s': 1500,
    'coordinates': [
      [100.3548088, -0.9099249],
      [100.4627099, -0.9148733],
    ],
  },
};

/// Jawaban server sungguhan dikirim sebagai byte UTF-8 (misalnya tanda "–").
http.Response jsonOk(Object body) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

ApiClient apiReturning(http.Response response) {
  final api = ApiClient(
    baseUrl: Uri.parse('https://server.test/api/v1'),
    tokenStore: MemoryTokenStore(),
    client: MockClient((_) async => response),
  );
  addTearDown(api.close);
  return api;
}

void main() {
  test('GET /rides dibaca menjadi Ride lengkap dengan jalur', () async {
    final repository = RemoteRideRepository(
      apiReturning(
        jsonOk({
          'data': [rideJson],
        }),
      ),
    );

    final rides = await repository.fetchRides();

    expect(repository.isSimulation, isFalse);
    expect(repository.rides, same(rides));
    final ride = rides.single;
    expect(ride.id, '7');
    expect(ride.driverName, 'Taris Rafivdean');
    expect(ride.driverRating, 4.8);
    expect(ride.origin, 'Jl. Khatib Sulaiman');
    expect(ride.destination, 'Kampus Unand Limau Manis');
    expect(ride.departureTime, '07.30');
    expect(ride.schedule, 'Senin–Jumat');
    expect(ride.seatsAvailable, 2);
    expect(ride.farePerPerson, 5000);
    final geography = ride.geography!;
    expect(geography.origin.address, 'Ulak Karang Utara, Padang');
    expect(geography.destination.address, '');
    expect(geography.route.points.first.latitude, -0.9099249);
    expect(geography.route.points.first.longitude, 100.3548088);
    expect(geography.route.distanceMeters, 13400);
  });

  test('Kolom wajib hilang menjadi invalidResponse, bukan crash', () async {
    final broken = Map<String, Object?>.of(rideJson)..remove('driver');
    final repository = RemoteRideRepository(
      apiReturning(
        jsonOk({
          'data': [broken],
        }),
      ),
    );

    expect(
      repository.fetchRides(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.kind,
          'kind',
          ApiErrorKind.invalidResponse,
        ),
      ),
    );
  });

  testWidgets('Provider memakai server bila ada ApiClient, lokal bila tidak', (
    tester,
  ) async {
    Future<RideRepository> resolve(ApiClient? client) async {
      late RideRepository found;
      await tester.pumpWidget(
        ApiClientProvider(
          client: client,
          tokenStore: MemoryTokenStore(),
          child: RideRepositoryProvider(
            child: Builder(
              builder: (context) {
                found = RideRepositoryScope.maybeOf(context)!;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      return found;
    }

    expect(
      await resolve(apiReturning(http.Response('[]', 200))),
      isA<RemoteRideRepository>(),
    );
    await tester.pumpWidget(const SizedBox());
    // Tanpa API_BASE_URL (seperti saat tes), aplikasi tetap memakai data latihan.
    expect(await resolve(null), isA<LocalRideRepository>());
  });
}
