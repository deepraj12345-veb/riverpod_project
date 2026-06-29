import 'dart:io';

void main() {
  final src = File(
    r'C:\Users\hp\.gemini\antigravity-ide\brain\3425822a-97ea-468e-abde-f353ee635677\media__1782211615681.png',
  );
  final dst = File(r'c:\Projects\veggie mart\riverpod_project\assets\logo.png');
  dst.parent.createSync(recursive: true);
  src.copySync(dst.path);
  // ignore: avoid_print
  print('Logo copied via Dart!');
}
