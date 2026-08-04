import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/app-logo.png');
  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return;

  // Find bounding box
  int minX = image.width;
  int minY = image.height;
  int maxX = 0;
  int maxY = 0;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      if (p.a > 10 && !(p.r > 240 && p.g > 240 && p.b > 240)) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  if (minX > maxX || minY > maxY) return;

  final croppedWidth = maxX - minX + 1;
  final croppedHeight = maxY - minY + 1;
  final cropped = img.copyCrop(image, x: minX, y: minY, width: croppedWidth, height: croppedHeight);

  // Increase padding heavily so it fits inside Android 12 circular mask!
  final size = croppedWidth > croppedHeight ? croppedWidth : croppedHeight;
  final paddedSize = (size * 1.6).toInt();
  
  final square = img.Image(width: paddedSize, height: paddedSize, numChannels: 4);
  for (final p in square) {
    p.r = 255;
    p.g = 255;
    p.b = 255;
    p.a = 255;
  }

  final dx = (paddedSize - croppedWidth) ~/ 2;
  final dy = (paddedSize - croppedHeight) ~/ 2;

  img.compositeImage(square, cropped, dstX: dx, dstY: dy);

  File('assets/app-logo-square.png').writeAsBytesSync(img.encodePng(square));
  print('Success');
}
