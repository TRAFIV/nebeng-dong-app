import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Avatar bulat berisi huruf pertama nama pengguna.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.brandSubtle,
      child: Text(
        initial,
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.brand),
      ),
    );
  }
}
