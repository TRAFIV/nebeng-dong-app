import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/booking/models/booking.dart';
import 'package:praktikum_mobile/features/booking/views/ajukan_tebengan_screen.dart';
import 'package:praktikum_mobile/features/booking/views/catatan_form_screen.dart';
import 'package:praktikum_mobile/features/booking/views/detail_pesanan_screen.dart';
import 'package:praktikum_mobile/features/booking/views/pesanan_saya_screen.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/ride_filter_screen.dart';
import 'package:praktikum_mobile/features/auth/views/login_screen.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/views/not_found_screen.dart';
import 'package:praktikum_mobile/shared/views/ride_detail_screen.dart';

abstract final class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';
  static const String myRoutes = '/my-routes';
  static const String postRoute = '/post-route';
  static const String rideFilter = '/ride-filter';
  static const String pesananSaya = '/pesanan-saya';
  static const String ajukanTebengan = '/ajukan-tebengan';
  static const String detailPesanan = '/detail-pesanan';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Archived driver entry points always fall through to 404.
      case myRoutes:
      case postRoute:
        return null;
      case rideFilter:
        final args = settings.arguments;
        if (args != null && args is! RideFilter) return null;
        return MaterialPageRoute<RideFilter>(
          settings: settings,
          builder: (_) => RideFilterScreen(
            initialFilter: args as RideFilter? ?? const RideFilter(),
          ),
        );
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
      case pesananSaya:
        // Argumen opsional: Ride untuk langsung membuka AjukanTebengan.
        final args = settings.arguments;
        return MaterialPageRoute<void>(
          builder: (_) =>
              PesananSayaScreen(initialRide: args is Ride ? args : null),
          settings: settings,
        );
      case ajukanTebengan:
        final arguments = settings.arguments;
        if (arguments is Ride) {
          // Return type Booking? agar Navigator.pop(context, booking) diterima pemanggil.
          return MaterialPageRoute<Booking>(
            builder: (_) => AjukanTebenganScreen(ride: arguments),
            settings: settings,
          );
        }
        return null;
      case detailPesanan:
        final arguments = settings.arguments;
        if (arguments is Booking) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailPesananScreen(booking: arguments),
            settings: settings,
          );
        }
        return null;
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
