import 'package:flutter/material.dart';

import 'package:praktikum_mobile/core/di/api_client_scope.dart';
import 'package:praktikum_mobile/core/di/auth_repository_scope.dart';
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

class NebengDongApp extends StatefulWidget {
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
  State<NebengDongApp> createState() => _NebengDongAppState();
}

class _NebengDongAppState extends State<NebengDongApp> {
  final _navigator = GlobalKey<NavigatorState>();
  final _messenger = GlobalKey<ScaffoldMessengerState>();

  /// Token ditolak server: kembali ke Login dan beri tahu penumpang.
  void _sessionExpired() {
    _navigator.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
    _messenger.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Sesi kamu habis. Masuk lagi, ya.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final widget = this.widget;
    final parent = MapServiceScope.maybeOf(context);
    return ApiClientProvider(
      client: widget.apiClient,
      onSessionExpired: _sessionExpired,
      child: AuthRepositoryProvider(
        child: BookingRepositoryProvider(
          repository: widget.bookingRepository,
          child: RideRepositoryProvider(
            repository: widget.rideRepository,
            child: CostRepositoryProvider(
              repository: widget.costRepository,
              child: RatingRepositoryProvider(
                repository: widget.ratingRepository,
                child: MapServiceProvider(
                  service: widget.mapService ?? parent?.service,
                  enableTiles: parent?.enableTiles ?? widget.enableMapTiles,
                  child: PassengerShellProvider(
                    child: MaterialApp(
                      navigatorKey: _navigator,
                      scaffoldMessengerKey: _messenger,
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
      ),
    );
  }
}
