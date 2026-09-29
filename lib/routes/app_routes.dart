import 'package:flutter/material.dart';

import '../models/ride.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/ride_detail_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';

  // Ditambahkan: route halaman Form Catatan.
  static const String catatanForm = '/catatan-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case home:
        final args = settings.arguments;

        if (args is String && args.trim().isNotEmpty) {
          return MaterialPageRoute<void>(
            builder: (_) => HomeScreen(userName: args),
            settings: settings,
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => NotFoundScreen(
            routeName: settings.name,
            message: 'Nama pengguna untuk membuka Home tidak valid.',
          ),
          settings: settings,
        );

      case detail:
        final args = settings.arguments;

        if (args is Ride) {
          return MaterialPageRoute<void>(
            builder: (_) => RideDetailScreen(ride: args),
            settings: settings,
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => NotFoundScreen(
            routeName: settings.name,
            message: 'Data tebengan untuk membuka Detail tidak valid.',
          ),
          settings: settings,
        );

      // Ditambahkan: String karena form mengembalikan teks catatan.
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
      builder: (_) => NotFoundScreen(
        routeName: settings.name,
      ),
      settings: settings,
    );
  }
}