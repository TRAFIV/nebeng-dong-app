import 'package:praktikum_mobile/core/network/api_exception.dart';

/// Objek JSON dari server.
typedef JsonMap = Map<String, Object?>;

/// Pembaca kolom JSON yang tegas: kolom hilang atau bertipe salah langsung
/// melempar [FormatException] dengan nama kolomnya, bukan error acak di layar.
extension JsonRead on JsonMap {
  T read<T>(String key) {
    final value = this[key];
    if (value is T) return value;
    throw FormatException('Kolom "$key" harus bertipe $T, didapat $value');
  }

  T? readOrNull<T>(String key) => this[key] == null ? null : read<T>(key);

  /// JSON tidak membedakan 5 dan 5.0, jadi angka pecahan dibaca dari num.
  double readDouble(String key) => read<num>(key).toDouble();

  JsonMap readMap(String key) => read<JsonMap>(key);

  List<JsonMap> readMapList(String key) =>
      read<List<Object?>>(key).map(asJsonMap).toList();
}

JsonMap asJsonMap(Object? value) {
  if (value is JsonMap) return value;
  throw FormatException('Harus objek JSON, didapat $value');
}

List<JsonMap> asJsonMapList(Object? value) {
  if (value is List) return value.map(asJsonMap).toList();
  throw FormatException('Harus daftar JSON, didapat $value');
}

/// Mengubah jawaban server menjadi model. Kesalahan bentuk data menjadi
/// [ApiException] jenis [ApiErrorKind.invalidResponse], sehingga ViewModel
/// cukup menangani satu jenis error.
T parseResponse<T>(Object? json, T Function(Object? json) parse) {
  try {
    return parse(json);
  } on FormatException catch (error) {
    throw ApiException(
      ApiErrorKind.invalidResponse,
      ApiException.defaultMessage(ApiErrorKind.invalidResponse),
      debugDetail: error.message,
    );
  } on TypeError catch (error) {
    throw ApiException(
      ApiErrorKind.invalidResponse,
      ApiException.defaultMessage(ApiErrorKind.invalidResponse),
      debugDetail: error.toString(),
    );
  }
}
