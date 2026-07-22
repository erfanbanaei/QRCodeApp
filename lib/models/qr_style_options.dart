import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

enum QrShapeStyle { classic, rounded, dots }

extension QrShapeStyleLabel on QrShapeStyle {
  String get label {
    switch (this) {
      case QrShapeStyle.classic:
        return 'کلاسیک';
      case QrShapeStyle.rounded:
        return 'گرد شده';
      case QrShapeStyle.dots:
        return 'نقطه‌ای';
    }
  }
}

enum QrEccLevel { low, medium, quartile, high }

extension QrEccLevelValue on QrEccLevel {
  int get value {
    switch (this) {
      case QrEccLevel.low:
        return QrErrorCorrectLevel.L;
      case QrEccLevel.medium:
        return QrErrorCorrectLevel.M;
      case QrEccLevel.quartile:
        return QrErrorCorrectLevel.Q;
      case QrEccLevel.high:
        return QrErrorCorrectLevel.H;
    }
  }

  String get label {
    switch (this) {
      case QrEccLevel.low:
        return 'کم (L)';
      case QrEccLevel.medium:
        return 'متوسط (M)';
      case QrEccLevel.quartile:
        return 'خوب (Q)';
      case QrEccLevel.high:
        return 'زیاد (H)';
    }
  }
}

@immutable
class QrStyleOptions {
  final Color foregroundColor;
  final Color backgroundColor;
  final bool useGradient;
  final Color gradientColor;
  final QrShapeStyle shapeStyle;
  final double roundFactor;
  final QrEccLevel eccLevel;
  final Uint8List? logoBytes;
  final double exportSize;

  const QrStyleOptions({
    this.foregroundColor = const Color(0xFF1A1A2E),
    this.backgroundColor = Colors.white,
    this.useGradient = false,
    this.gradientColor = const Color(0xFF6C5CE7),
    this.shapeStyle = QrShapeStyle.rounded,
    this.roundFactor = 1,
    this.eccLevel = QrEccLevel.quartile,
    this.logoBytes,
    this.exportSize = 1024,
  });

  PrettyQrShape get shape {
    switch (shapeStyle) {
      case QrShapeStyle.classic:
        return PrettyQrSquaresSymbol(
          color: _brushColor,
          rounding: 0,
        );
      case QrShapeStyle.rounded:
        return PrettyQrSmoothSymbol(
          color: _brushColor,
          roundFactor: roundFactor,
        );
      case QrShapeStyle.dots:
        return PrettyQrDotsSymbol(
          color: _brushColor,
        );
    }
  }

  Color get _brushColor {
    if (!useGradient) return foregroundColor;
    return PrettyQrBrush.gradient(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [foregroundColor, gradientColor],
      ),
    );
  }

  QrStyleOptions copyWith({
    Color? foregroundColor,
    Color? backgroundColor,
    bool? useGradient,
    Color? gradientColor,
    QrShapeStyle? shapeStyle,
    double? roundFactor,
    QrEccLevel? eccLevel,
    Uint8List? logoBytes,
    bool clearLogo = false,
    double? exportSize,
  }) {
    return QrStyleOptions(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      useGradient: useGradient ?? this.useGradient,
      gradientColor: gradientColor ?? this.gradientColor,
      shapeStyle: shapeStyle ?? this.shapeStyle,
      roundFactor: roundFactor ?? this.roundFactor,
      eccLevel: eccLevel ?? this.eccLevel,
      logoBytes: clearLogo ? null : (logoBytes ?? this.logoBytes),
      exportSize: exportSize ?? this.exportSize,
    );
  }
}
