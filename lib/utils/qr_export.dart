import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' show GlobalKey;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'web_saver_io.dart' if (dart.library.js_interop) 'web_saver_web.dart' as web_saver;

class QrExport {
  QrExport._();

  static Future<Uint8List?> captureBoundary(GlobalKey key, {double pixelRatio = 3}) async {
    final context = key.currentContext;
    if (context == null) return null;
    final boundary = context.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  static Future<void> saveToGallery(Uint8List bytes) async {
    final name = 'qrcode-${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      await web_saver.downloadBytes(bytes, '$name.png');
      return;
    }
    // موبایل: در صورت نبود دسترسی، درخواست بده.
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      final granted = await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        throw Exception('دسترسی به گالری داده نشد');
      }
    }
    await Gal.putImageBytes(bytes, album: 'QR Code', name: name);
  }

  static Future<File> writeToTempFile(Uint8List bytes, {String name = 'qrcode'}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name-${DateTime.now().millisecondsSinceEpoch}.png');
    return file.writeAsBytes(bytes);
  }

  static Future<void> share(Uint8List bytes, {String? text}) async {
    if (kIsWeb) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: 'image/png', name: 'qrcode.png')],
          text: text,
          fileNameOverrides: const ['qrcode.png'],
        ),
      );
      return;
    }
    final file = await writeToTempFile(bytes);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: text),
    );
  }
}
