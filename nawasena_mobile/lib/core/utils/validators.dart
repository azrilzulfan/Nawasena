class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong.';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Format email tidak valid.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong.';
    if (value.length < 8) return 'Password minimal 8 karakter.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong.';
    if (value != original) return 'Password tidak cocok.';
    return null;
  }

  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName tidak boleh kosong.';
    return null;
  }

  static String? positiveInteger(String? value, {String fieldName = 'Jumlah'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName tidak boleh kosong.';
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return '$fieldName harus berupa angka.';
    if (parsed <= 0) return '$fieldName harus lebih dari 0.';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama lengkap tidak boleh kosong.';
    if (value.trim().length < 3) return 'Nama minimal 3 karakter.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nomor telepon tidak boleh kosong.';
    final cleaned = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (cleaned.length < 9 || cleaned.length > 15) return 'Nomor telepon tidak valid.';
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) return 'Nomor telepon hanya boleh berisi angka.';
    return null;
  }
}