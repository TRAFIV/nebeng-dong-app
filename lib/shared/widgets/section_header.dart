import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Judul bagian dengan tautan aksi di kanan (komponen Figma `Section Header`).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;

  /// Teks tautan di kanan; tautan disembunyikan bila `null`.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final action = actionLabel;
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.headingMedium)),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }
}
