import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final screenMap = {
    'auth': 'auth',
    'cart': 'cart',
    'categories': 'categories',
    'checkout': 'checkout',
    'home': 'home',
    'orders': 'orders',
    'product': 'product',
    'profile': 'profile',
    'shell': 'shell',
    'splash': 'splash',
    'wishlist': 'wishlist',
  };

  // 1. Move files
  for (final entry in screenMap.entries) {
    final srcDir = Directory('lib/features/${entry.key}/presentation/pages');
    final destDir = Directory('lib/presentation/screens/${entry.value}');
    
    if (srcDir.existsSync()) {
      if (!destDir.existsSync()) {
        destDir.createSync(recursive: true);
      }
      for (final file in srcDir.listSync().whereType<File>()) {
        final fileName = file.uri.pathSegments.last;
        file.renameSync('${destDir.path}/$fileName');
        print('Moved $fileName to ${destDir.path}');
      }
    }
  }

  // 2. Also move providers back if any
  final providerMap = {
    'auth': 'auth/presentation/providers',
    'cart': 'cart/presentation/controllers',
    'categories': 'categories/presentation/providers',
    'home': 'home/presentation/providers',
    'home_ctrl': 'home/presentation/controllers',
    'orders': 'orders/presentation/controllers',
    'profile': 'profile/presentation/controllers',
    'wishlist': 'wishlist/presentation/controllers',
  };

  final destProvDir = Directory('lib/presentation/providers');
  if (!destProvDir.existsSync()) {
    destProvDir.createSync(recursive: true);
  }

  for (final entry in providerMap.entries) {
    final srcDir = Directory('lib/features/${entry.value}');
    if (srcDir.existsSync()) {
      for (final file in srcDir.listSync().whereType<File>()) {
        final fileName = file.uri.pathSegments.last;
        file.renameSync('${destProvDir.path}/$fileName');
        print('Moved provider $fileName to ${destProvDir.path}');
      }
    }
  }

  // 3. Update imports
  for (final file in files) {
    if (!file.existsSync()) continue;
    String content = file.readAsStringSync();
    bool changed = false;

    // Screens
    for (final entry in screenMap.entries) {
      final oldPath = 'package:veggie_mart/features/${entry.value}/presentation/pages/';
      final newPath = 'package:veggie_mart/presentation/screens/${entry.key}/';
      if (content.contains(oldPath)) {
        content = content.replaceAll(oldPath, newPath);
        changed = true;
      }
    }

    // Providers
    for (final entry in providerMap.entries) {
      final oldPath = 'package:veggie_mart/features/${entry.value}/';
      final newPath = 'package:veggie_mart/presentation/providers/';
      if (content.contains(oldPath)) {
        content = content.replaceAll(oldPath, newPath);
        changed = true;
      }
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated imports in ${file.path}');
    }
  }
}
