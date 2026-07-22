import 'dart:io';
import 'package:image/image.dart' as img;
void main() {
  final im = img.decodePng(File('assets/splash_background.png').readAsBytesSync())!;
  for (int y = 1600; y < 1700; y += 5) {
    final p = im.getPixel(540, y);
    print('y=$y -> ${p.r},${p.g},${p.b}');
  }
}
