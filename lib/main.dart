import 'package:flutter/material.dart';

import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/core/di/map_service_scope.dart';
import 'package:praktikum_mobile/core/di/ride_repository_scope.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';

void main() {
  runApp(const NebengDongApp());
}

class NebengDongApp extends StatelessWidget {
  const NebengDongApp({
    super.key,
    this.mapService,
    this.rideRepository,
    this.enableMapTiles = true,
  });
  final MapService? mapService;
  final RideRepository? rideRepository;
  final bool enableMapTiles;

  @override
  Widget build(BuildContext context) {
    final parent = MapServiceScope.maybeOf(context);
    return RideRepositoryProvider(
      repository: rideRepository,
      child: MapServiceProvider(
        service: mapService ?? parent?.service,
        enableTiles: parent?.enableTiles ?? enableMapTiles,
        child: MaterialApp(
          title: 'Nebeng Dong',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: AppRoutes.login,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          onUnknownRoute: AppRoutes.onUnknownRoute,
        ),
      ),
    );
  }
}
