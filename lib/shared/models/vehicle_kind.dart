/// Jenis kendaraan tebengan.
enum VehicleKind {
  car('Mobil'),
  motor('Motor');

  const VehicleKind(this.label);
  final String label;

  /// Sementara server belum mengirim jenis kendaraan: kapasitas 1 kursi
  /// hampir pasti motor (satu penumpang), selebihnya mobil.
  static VehicleKind fromSeatCapacity(int capacity) =>
      capacity <= 1 ? motor : car;
}
