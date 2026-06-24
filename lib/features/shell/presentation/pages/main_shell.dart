import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:riverpod_project/features/cart/presentation/controllers/cart_controller.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/core/widgets/custom_text.dart';

import 'package:flutter/rendering.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> with SingleTickerProviderStateMixin {
  late final AnimationController _hideAnimCtrl;

  @override
  void initState() {
    super.initState();
    _hideAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _hideAnimCtrl.dispose();
    super.dispose();
  }

  static const _tabs = [
    _Tab(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', route: '/home'),
    _Tab(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, label: 'Categories', route: '/categories'),
    _Tab(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart_rounded, label: 'Cart', route: '/cart'),
    _Tab(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile', route: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/home') || loc.startsWith('/product')) return 0;
    if (loc.startsWith('/categories')) return 1;
    if (loc.startsWith('/cart')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_hideAnimCtrl.status != AnimationStatus.reverse) {
              _hideAnimCtrl.reverse();
            }
          } else if (notification.direction == ScrollDirection.forward) {
            if (_hideAnimCtrl.status != AnimationStatus.forward) {
              _hideAnimCtrl.forward();
            }
          }
          return false;
        },
        child: widget.child,
      ),
      bottomNavigationBar: SizeTransition(
        sizeFactor: _hideAnimCtrl,
        axisAlignment: -1.0,
        child: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textGrey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => context.go(_tabs[i].route),
        items: List.generate(_tabs.length, (i) {
          final tab = _tabs[i];
          final isSelected = index == i;
          final isCart = tab.route == '/cart';

          Widget iconWidget = Icon(
            isSelected ? tab.activeIcon : tab.icon,
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey,
          );

          if (isCart && cartCount > 0) {
            iconWidget = badges.Badge(
              badgeContent: CustomText(
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

          return BottomNavigationBarItem(
            icon: iconWidget,
            label: tab.label,
          );
        }),
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
