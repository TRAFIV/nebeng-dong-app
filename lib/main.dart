import 'package:flutter/material.dart';

import 'package:praktikum_mobile/core/di/api_client_scope.dart';
import 'package:praktikum_mobile/core/di/booking_repository_scope.dart';
import 'package:praktikum_mobile/core/di/map_service_scope.dart';
import 'package:praktikum_mobile/core/di/ride_repository_scope.dart';
import 'package:praktikum_mobile/features/booking/data/booking_repository.dart';
import 'package:praktikum_mobile/core/di/cost_repository_scope.dart';
import 'package:praktikum_mobile/core/di/rating_repository_scope.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/core/network/api_client.dart';
import 'package:praktikum_mobile/features/reputation/data/rating_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/shared/widgets/passenger_shell_scope.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

void main() {
  runApp(const NebengDongApp());
}

class NebengDongApp extends StatelessWidget {
  const NebengDongApp({
    super.key,
    this.apiClient,
    this.mapService,
    this.rideRepository,
    this.bookingRepository,
    this.costRepository,
    this.ratingRepository,
    this.enableMapTiles = true,
  });

  /// Klien REST suntikan untuk tes; tanpa ini dibuat dari `API_BASE_URL`.
  final ApiClient? apiClient;
  final MapService? mapService;
  final RideRepository? rideRepository;
  final BookingRepository? bookingRepository;
  final CostRepository? costRepository;
  final RatingRepository? ratingRepository;
  final bool enableMapTiles;

  @override
  Widget build(BuildContext context) {
    final parent = MapServiceScope.maybeOf(context);
    return ApiClientProvider(
      client: apiClient,
      child: BookingRepositoryProvider(
        repository: bookingRepository,
        child: RideRepositoryProvider(
          repository: rideRepository,
          child: CostRepositoryProvider(
            repository: costRepository,
            child: RatingRepositoryProvider(
              repository: ratingRepository,
              child: MapServiceProvider(
                service: mapService ?? parent?.service,
                enableTiles: parent?.enableTiles ?? enableMapTiles,
                child: PassengerShellProvider(
                  child: MaterialApp(
                    title: 'Nebeng Dong',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light,
                    initialRoute: AppRoutes.login,
                    onGenerateRoute: AppRoutes.onGenerateRoute,
                    onUnknownRoute: AppRoutes.onUnknownRoute,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
