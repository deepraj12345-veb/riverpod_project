import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

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

  for (final file in files) {
    if (!file.existsSync()) continue;
    String content = file.readAsStringSync();
    bool changed = false;

    // Screens
    for (final entry in screenMap.entries) {
      final oldPath =
          'package:veggie_mart/features/${entry.value}/presentation/pages/';
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
