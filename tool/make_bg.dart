import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

int _lerp(int a, int b, double t) => (a + (b - a) * t).round().clamp(0, 255);
double _smoothstep(double e0, double e1, double x) {
  final t = ((x - e0) / (e1 - e0)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

void main() {
  const w = 1080, h = 1920;
  final canvas = img.Image(width: w, height: h, numChannels: 3);

  const bg = [0x0E, 0x0B, 0x1A];
  const glow = [0x40, 0x30, 0x72];

  final cx = w / 2;
  final cy = h * 0.46;
  final rng = math.Random(7);
  const rInner = 90.0;
  const rOuter = 620.0;

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final dx = x - cx, dy = y - cy;
      final dist = math.sqrt(dx * dx + dy * dy);
      final t = _smoothstep(rInner, rOuter, dist); // یک منحنی پیوسته، بدون نقطه‌ی شکست
      var r = _lerp(glow[0], bg[0], t);
      var g = _lerp(glow[1], bg[1], t);
      var b = _lerp(glow[2], bg[2], t);
      final n = (rng.nextDouble() - 0.5) * 3;
      r = (r + n).round().clamp(0, 255);
      g = (g + n).round().clamp(0, 255);
      b = (b + n).round().clamp(0, 255);
      canvas.setPixelRgb(x, y, r, g, b);
    }
  }

  File('assets/splash_background.png').writeAsBytesSync(img.encodePng(canvas));
  print('wrote assets/splash_background.png ${w}x$h');
}
