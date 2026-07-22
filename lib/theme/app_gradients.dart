import 'package:flutter/material.dart';

/// مجموعه رنگ‌ها و گرادیان‌های اصلی برند اپلیکیشن.
class AppGradients {
  AppGradients._();

  // رنگ‌های پایه برند
  static const Color violet = Color(0xFF7C4DFF);
  static const Color indigo = Color(0xFF5B6BFF);
  static const Color magenta = Color(0xFFB84DFF);
  static const Color cyan = Color(0xFF38BDF8);

  /// گرادیان اصلی برند (بنفش به آبی نیلی) — برای هدر، دکمه‌ها و کد پیش‌فرض.
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C4DFF), Color(0xFF5B6BFF)],
  );

  /// گرادیان پرانرژی (بنفش به صورتی) برای هدر صفحه ساخت.
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFF3B82F6)],
  );

  /// گرادیان صورتی-بنفش برای لهجه‌های تزئینی.
  static const LinearGradient candy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB84DFF), Color(0xFF7C4DFF)],
  );

  /// سایه‌ی درخشان برای دکمه‌های اصلی.
  static List<BoxShadow> glow(Color color, {double opacity = 0.4, double blur = 24, double y = 10}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blur,
        offset: Offset(0, y),
      ),
    ];
  }
}
