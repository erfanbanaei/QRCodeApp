import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:qr/qr.dart';

/// یک تصویر PNG ساده و تمیز از کد QR می‌سازد، مستقل از درخت ویجت‌ها.
/// برای اشتراک‌گذاری آیتم‌های تاریخچه که سبک ظاهری ذخیره نشده استفاده می‌شود.
class QrImageRenderer {
  QrImageRenderer._();

  static Future<Uint8List> renderToPng(
    String data, {
    int size = 900,
    int errorCorrectLevel = QrErrorCorrectLevel.M,
  }) async {
    final qrCode = QrCode.fromData(data: data, errorCorrectLevel: errorCorrectLevel);
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;

    const quietZoneModules = 4;
    final totalModules = moduleCount + quietZoneModules * 2;
    final moduleSize = size / totalModules;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    final darkPaint = ui.Paint()..color = const ui.Color(0xFF000000);
    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (!qrImage.isDark(row, col)) continue;
        canvas.drawRect(
          ui.Rect.fromLTWH(
            (quietZoneModules + col) * moduleSize,
            (quietZoneModules + row) * moduleSize,
            moduleSize,
            moduleSize,
          ),
          darkPaint,
        );
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
