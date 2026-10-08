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
  static const String catatanForm = '/catatan-form';

  /// Argument route [home] adalah nama pengguna (`String`).
  /// Argument route [detail] adalah [Ride] yang dipilih.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case home:
        final args = settings.arguments;
        return MaterialPageRoute<void>(
          builder: (_) => HomeScreen(userName: args is String ? args : 'Kamu'),
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
        return null; // data salah/kosong -> halaman 404
      case catatanForm:
        // <String> karena layar ini mengembalikan teks saat ditutup
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null; // route tidak terdaftar -> halaman 404
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
