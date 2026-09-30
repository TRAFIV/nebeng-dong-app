class Validators {
  Validators._();

  static String? requiredField(String? value, {String fieldName = 'Field ini', String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? '$fieldName wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, fieldName: 'Email');
    if (requiredError != null) return requiredError;

    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? campusEmail(String? value, String domain) {
    final requiredError = requiredField(value, fieldName: 'Email kampus', customMessage: 'Email kampusnya diisi dulu, ya');
    if (requiredError != null) return requiredError;

    final email = value!.trim();
    final pattern = RegExp('^[^@\\s]+@([a-z0-9-]+\\.)*${RegExp.escape(domain)}\$', caseSensitive: false);
    if (!pattern.hasMatch(email)) {
      return 'Pakai email kampus ($domain), ya!';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'Field ini',
  }) {
    final requiredError = requiredField(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    if (value!.trim().length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  static String? rating(String? value) {
    final requiredError = requiredField(value, fieldName: 'Rating');
    if (requiredError != null) return requiredError;

    final number = int.tryParse(value!.trim());
    if (number == null) return 'Rating harus berupa angka';
    if (number < 1 || number > 5) return 'Rating harus di antara 1 sampai 5';
    return null;
  }
}
