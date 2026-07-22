import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('generate wordmark png', (tester) async {
    final fontData = await File('assets/fonts/IRANYekanExtraBold.ttf').readAsBytes();
    final loader = FontLoader('IRANYekan')..addFont(Future.value(fontData.buffer.asByteData()));
    await loader.load();

    const key = ValueKey('wordmark');
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: const Text(
              'QR Code',
              style: TextStyle(
                fontFamily: 'IRANYekan',
                fontWeight: FontWeight.w800,
                fontSize: 46,
                color: Color(0xFFE8E3FF),
                letterSpacing: 1.6,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final boundary = tester.renderObject(find.byKey(key)) as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 4);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('assets/splash_wordmark.png').writeAsBytes(byteData!.buffer.asUint8List());
    // ignore: avoid_print
    print('wrote assets/splash_wordmark.png ${image.width}x${image.height}');
  });
}
