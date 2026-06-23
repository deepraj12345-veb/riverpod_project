import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:riverpod_project/features/cart/presentation/controllers/cart_controller.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _Tab(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', route: '/home'),
    _Tab(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, label: 'Categories', route: '/categories'),
    _Tab(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart_rounded, label: 'Cart', route: '/cart'),
    _Tab(icon: Icons.refresh_rounded, activeIcon: Icons.refresh_rounded, label: 'Order Again', route: '/order-again'),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/home') || loc.startsWith('/product')) return 0;
    if (loc.startsWith('/categories')) return 1;
    if (loc.startsWith('/cart')) return 2;
    if (loc.startsWith('/order-again')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _currentIndex(context);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFF0F0F0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isSelected = index == i;
                final isCart = tab.route == '/cart';

                Widget iconWidget = Icon(
                  isSelected ? tab.activeIcon : tab.icon,
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey,
                  size: 24,
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
                    child: iconWidget,
                  );
                }

                return GestureDetector(
                  onTap: () => context.go(tab.route),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        iconWidget,
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isSelected ? 16 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
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

class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
