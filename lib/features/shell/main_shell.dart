import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:riverpod_project/core/providers/app_providers.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  // 3-tab nav: Home, Cart list, Setting
  static const _tabs = [
    _TabItem(
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: 'Home',
      route: '/home',
    ),
    _TabItem(
      activeIcon: Icons.shopping_bag_rounded,
      inactiveIcon: Icons.shopping_bag_outlined,
      label: 'Cart list',
      route: '/cart',
    ),
    _TabItem(
      activeIcon: Icons.settings_rounded,
      inactiveIcon: Icons.settings_outlined,
      label: 'Setting',
      route: '/profile',
    ),
  ];

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/cart')) return 1;
    if (location.startsWith('/profile') || location.startsWith('/wishlist')) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _getCurrentIndex(context);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isSelected = currentIndex == index;
                final isCart = tab.route == '/cart';

                Widget iconWidget = Icon(
                  isSelected ? tab.activeIcon : tab.inactiveIcon,
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.textGrey,
                  size: 26,
                );

                if (isCart && cartCount > 0) {
                  iconWidget = badges.Badge(
                    badgeContent: Text(
                      cartCount > 9 ? '9+' : '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: AppTheme.primaryGreen,
                      padding: EdgeInsets.all(4),
                    ),
                    child: Icon(
                      isSelected ? tab.activeIcon : tab.inactiveIcon,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.textGrey,
                      size: 26,
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => context.go(tab.route),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      iconWidget,
                      const SizedBox(height: 4),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Active dot indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isSelected ? 18 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final String route;
  const _TabItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.route,
  });
}
