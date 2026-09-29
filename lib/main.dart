import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NebengDongApp());
}

class NebengDongApp extends StatelessWidget {
  const NebengDongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nebeng Dong',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // Diubah: halaman awal ditentukan melalui named route.
      initialRoute: AppRoutes.login,

      // Ditambahkan: gunakan pengaturan navigasi dari AppRoutes.
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}