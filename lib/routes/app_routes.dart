import 'package:flutter/material.dart';

import '../models/ride.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/ride_detail_screen.dart';

abstract final class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case home:
        final arguments = settings.arguments;
        if (arguments == null || arguments is String) {
          return MaterialPageRoute<void>(
            builder: (_) =>
                HomeScreen(userName: arguments as String? ?? 'Kamu'),
            settings: settings,
          );
        }
        return null;
      case detail:
        final arguments = settings.arguments;
        if (arguments is Ride) {
          return MaterialPageRoute<void>(
            builder: (_) => RideDetailScreen(ride: arguments),
            settings: settings,
          );
        }
        return null;
      case catatanForm:
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
