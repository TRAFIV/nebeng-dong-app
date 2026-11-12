import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/costs/models/cost_share.dart';
import 'package:praktikum_mobile/shared/widgets/status_badge.dart';

/// Badge status pembayaran memakai komponen `Badge` bersama.
class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({super.key, required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final (tone, icon) = switch (status) {
      PaymentStatus.unreported => (StatusTone.neutral, Icons.schedule),
      PaymentStatus.pendingConfirmation => (
        StatusTone.brand,
        Icons.hourglass_top,
      ),
      PaymentStatus.confirmed => (StatusTone.success, Icons.check_circle),
    };
    return StatusBadge(label: status.label, tone: tone, icon: icon);
  }
}

/// Badge tahap ongkos: estimasi, final, atau belum diatur.
class FareStageBadge extends StatelessWidget {
  const FareStageBadge({super.key, required this.stage});

  final FareStage stage;

  @override
  Widget build(BuildContext context) {
    final tone = switch (stage) {
      FareStage.estimate => StatusTone.brand,
      FareStage.finalized => StatusTone.success,
      FareStage.unset => StatusTone.neutral,
    };
    return StatusBadge(label: stage.label, tone: tone);
  }
}
