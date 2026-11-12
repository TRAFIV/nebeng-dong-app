import 'package:flutter/material.dart';

import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';

/// Halaman cadangan ketika route tidak dikenal atau argument tidak valid.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({
    super.key,
    this.routeName,
    this.message = 'Halaman yang kamu tuju belum tersedia.',
  });

  final String? routeName;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 72),
              const SizedBox(height: AppSpacing.sm),
              Text('404', style: textTheme.displaySmall),
              const SizedBox(height: AppSpacing.sm),
              Text(message, textAlign: TextAlign.center),
              if (routeName != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text('Route: $routeName', style: textTheme.bodySmall),
              ],
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
