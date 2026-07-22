import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _capture(WidgetTester tester, Key key, String path, double pr) async {
  final boundary = tester.renderObject(find.byKey(key)) as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pr);
  final bd = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = bd!.buffer.asUint8List();
  await tester.runAsync(() async => File(path).writeAsBytes(bytes));
  // ignore: avoid_print
  print('WROTE $path ${image.width}x${image.height}');
}

void main() {
  testWidgets('generate splash assets', (tester) async {
    await tester.runAsync(() async {
      final fontData = await File('assets/fonts/IRANYekanExtraBold.ttf').readAsBytes();
      final loader = FontLoader('IRANYekan')..addFont(Future.value(fontData.buffer.asByteData()));
      await loader.load();
    });

    // ---- بَج اسپلش: دایره‌ی گرادیانیِ برند + آیکون QR سفید ----
    // بوم ۱۱۵۲ (استاندارد اندروید ۱۲)، بَج داخل ناحیه‌ی امن دایره‌ای ۷۶۸px.
    const badgeKey = ValueKey('badge');
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: badgeKey,
            child: Container(
              alignment: Alignment.center,
              width: 288,
              height: 288,
              child: Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C4DFF), Color(0xFF5B6BFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.55),
                      blurRadius: 44,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 104),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await _capture(tester, badgeKey, 'assets/splash_logo.png', 4);

    // ---- نوشته‌ی برند ----
    const wordKey = ValueKey('word');
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: wordKey,
            child: Container(
              width: 420,
              height: 90,
              alignment: Alignment.center,
              color: const Color(0x00000000),
              child: const Text(
                'QR Code',
                style: TextStyle(
                  fontFamily: 'IRANYekan',
                  fontWeight: FontWeight.w800,
                  fontSize: 44,
                  color: Color(0xFFECE9FF),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await _capture(tester, wordKey, 'assets/splash_wordmark.png', 4);
  });
}
