import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/costs/models/payment_status.dart';
import 'package:praktikum_mobile/shared/widgets/status_badge.dart';

/// Badge status pembayaran dengan warna sesuai tahapnya.
class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({super.key, required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final tone = switch (status) {
      PaymentStatus.belumBayar => StatusTone.brand,
      PaymentStatus.menungguKonfirmasi => StatusTone.neutral,
      PaymentStatus.lunas => StatusTone.success,
    };
    return StatusBadge(label: status.label, tone: tone);
  }
}
