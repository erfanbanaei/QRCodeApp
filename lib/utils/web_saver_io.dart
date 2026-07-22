import 'dart:typed_data';

/// پیاده‌سازی پیش‌فرض (غیر وب) — روی موبایل هرگز فراخوانی نمی‌شود.
Future<void> downloadBytes(Uint8List bytes, String filename) async {
  throw UnsupportedError('دانلود مرورگری فقط روی وب در دسترس است.');
}
