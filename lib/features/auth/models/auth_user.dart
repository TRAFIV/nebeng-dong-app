/// Penumpang yang sedang masuk.
class AuthUser {
  const AuthUser({required this.name, this.id, this.email});

  final String name;
  final String? id;
  final String? email;

  /// Nama sapaan di Cari: kata pertama, mis. "Mikail Samyth" → "Mikail".
  String get firstName {
    final first = name.trim().split(RegExp(r'\s+')).first;
    return first.isEmpty ? 'Kamu' : first;
  }
}
