import 'package:flutter/material.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/legacy/driver/views/my_routes_screen.dart';
import 'package:praktikum_mobile/legacy/driver/views/post_route_screen.dart';

/// Archive regression harness only; never imported by the active app.
abstract final class LegacyDriverRoutes {
  static const myRoutes = '/my-routes';
  static const postRoute = '/post-route';
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    if (args is! RouteManagementArguments) return null;
    if (settings.name == myRoutes) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => MyRoutesScreen(
          repository: args.repository,
          userName: args.userName,
        ),
      );
    }
    if (settings.name == postRoute) {
      return MaterialPageRoute<Ride>(
        settings: settings,
        builder: (_) => PostRouteScreen(
          repository: args.repository,
          driverName: args.userName,
          initialRide: args.ride,
        ),
      );
    }
    return null;
  }
}

class RouteManagementArguments {
  const RouteManagementArguments({
    required this.repository,
    required this.userName,
    this.ride,
  });
  final LegacyDriverRepository repository;
  final String userName;
  final Ride? ride;
}
