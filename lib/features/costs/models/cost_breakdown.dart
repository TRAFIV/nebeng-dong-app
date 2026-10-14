import 'package:praktikum_mobile/features/costs/models/payment_status.dart';
import 'package:praktikum_mobile/features/costs/utils/cost_splitter.dart';

/// Bagian ongkos satu penumpang (entitas CostShare pada PRD 2.5).
class CostShare {
  const CostShare({
    required this.passengerName,
    required this.amount,
    required this.status,
    this.isCurrentUser = false,
  });

  final String passengerName;

  /// Nominal bagian dalam rupiah.
  final int amount;
  final PaymentStatus status;

  /// `true` untuk akun yang sedang login, ditampilkan sebagai "(Kamu)".
  final bool isCurrentUser;

  CostShare copyWith({PaymentStatus? status}) => CostShare(
    passengerName: passengerName,
    amount: amount,
    status: status ?? this.status,
    isCurrentUser: isCurrentUser,
  );
}

/// Rincian ongkos satu perjalanan: total dan bagian tiap penumpang.
class CostBreakdown {
  const CostBreakdown({
    required this.tripId,
    required this.origin,
    required this.destination,
    required this.departureLabel,
    required this.driverName,
    required this.totalFare,
    required this.shares,
  });

  /// Membuat rincian dengan membagi [totalFare] memakai [CostSplitter].
  ///
  /// [currentUserIndex] menandai penumpang yang sedang login.
  /// [initialStatuses] mengisi status awal per indeks; default belum bayar.
  factory CostBreakdown.split({
    required String tripId,
    required String origin,
    required String destination,
    required String departureLabel,
    required String driverName,
    required int totalFare,
    required List<String> passengerNames,
    required int currentUserIndex,
    Map<int, PaymentStatus> initialStatuses = const {},
  }) {
    if (currentUserIndex < 0 || currentUserIndex >= passengerNames.length) {
      throw RangeError.index(
        currentUserIndex,
        passengerNames,
        'currentUserIndex',
      );
    }
    final amounts = CostSplitter.split(totalFare, passengerNames.length);
    return CostBreakdown(
      tripId: tripId,
      origin: origin,
      destination: destination,
      departureLabel: departureLabel,
      driverName: driverName,
      totalFare: totalFare,
      shares: [
        for (var i = 0; i < passengerNames.length; i++)
          CostShare(
            passengerName: passengerNames[i],
            amount: amounts[i],
            status: initialStatuses[i] ?? PaymentStatus.belumBayar,
            isCurrentUser: i == currentUserIndex,
          ),
      ],
    );
  }

  final String tripId;
  final String origin;
  final String destination;

  /// Misalnya "Kamis, 1 Okt · 07.30".
  final String departureLabel;
  final String driverName;
  final int totalFare;
  final List<CostShare> shares;

  int get passengerCount => shares.length;

  /// Bagian milik penumpang yang sedang login.
  CostShare get myShare => shares.firstWhere((share) => share.isCurrentUser);

  /// Salinan rincian dengan status milik penumpang login diganti.
  /// Status penumpang lain tidak berubah.
  CostBreakdown withMyStatus(PaymentStatus status) => CostBreakdown(
    tripId: tripId,
    origin: origin,
    destination: destination,
    departureLabel: departureLabel,
    driverName: driverName,
    totalFare: totalFare,
    shares: [
      for (final share in shares)
        share.isCurrentUser ? share.copyWith(status: status) : share,
    ],
  );
}
