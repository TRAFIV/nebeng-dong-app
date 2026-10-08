import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/shared/utils/validators.dart';

class CatatanFormViewModel extends ViewModel {
  String? validate(String? value) =>
      Validators.minLength(value, 5, fieldName: 'Catatan');

  String? save(String value) =>
      isDisposed || validate(value) != null ? null : value.trim();
}
