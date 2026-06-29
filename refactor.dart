import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    // 1. Widgets
    if (content.contains('package:veggie_mart/presentation/widgets/')) {
      content = content.replaceAll('package:veggie_mart/presentation/widgets/', 'package:veggie_mart/core/widgets/');
      changed = true;
    }

    // 2. Screens -> Features mapping
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

    for (final entry in screenMap.entries) {
      final oldPath = 'package:veggie_mart/presentation/screens/${entry.key}/';
      final newPath = 'package:veggie_mart/features/${entry.value}/presentation/pages/';
      if (content.contains(oldPath)) {
        content = content.replaceAll(oldPath, newPath);
        changed = true;
      }
    }

    // 3. Providers -> Features mapping
    final providerMap = {
      'auth_provider.dart': 'auth/presentation/providers/auth_provider.dart',
      'auth_state.dart': 'auth/presentation/providers/auth_state.dart',
      'cart_controller.dart': 'cart/presentation/controllers/cart_controller.dart',
      'category_provider.dart': 'categories/presentation/providers/category_provider.dart',
      'dashboard_provider.dart': 'home/presentation/providers/dashboard_provider.dart',
      'home_controller.dart': 'home/presentation/controllers/home_controller.dart',
      'orders_controller.dart': 'orders/presentation/controllers/orders_controller.dart',
      'profile_controller.dart': 'profile/presentation/controllers/profile_controller.dart',
      'wishlist_controller.dart': 'wishlist/presentation/controllers/wishlist_controller.dart',
    };

    for (final entry in providerMap.entries) {
      final oldPath = 'package:veggie_mart/presentation/providers/${entry.key}';
      final newPath = 'package:veggie_mart/features/${entry.value}';
      if (content.contains(oldPath)) {
        content = content.replaceAll(oldPath, newPath);
        changed = true;
      }
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
