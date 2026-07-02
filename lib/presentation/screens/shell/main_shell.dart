import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:veggie_mart/presentation/providers/cart_controller.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/core/widgets/floating_cart_bar.dart';
import 'package:veggie_mart/presentation/screens/home/home_page.dart';
import 'package:veggie_mart/presentation/screens/categories/categories_page.dart';
import 'package:veggie_mart/presentation/screens/cart/cart_page.dart';
import 'package:veggie_mart/presentation/screens/profile/profile_page.dart';

import 'package:flutter/rendering.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hideAnimCtrl;
  int _currentTabIndex = 0;

  // Cached widget instances — created only once per tab, then kept alive
  late final List<Widget?> _cachedPages;

  // Tab page builders — called only on first visit
  static const List<Widget Function()> _pageBuilders = [
    _buildHome,
    _buildCategories,
    _buildCart,
    _buildProfile,
  ];

  static Widget _buildHome() => const HomePage();
  static Widget _buildCategories() => const CategoriesPage();
  static Widget _buildCart() => const CartPage();
  static Widget _buildProfile() => const ProfilePage();

  @override
  void initState() {
    super.initState();
    _hideAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    // Pre-build only Home tab; others will be lazily built on first visit
    _cachedPages = List<Widget?>.filled(_pageBuilders.length, null);
    _cachedPages[0] = _pageBuilders[0](); // Home pre-built
  }

  @override
  void dispose() {
    _hideAnimCtrl.dispose();
    super.dispose();
  }

  static const _tabs = [
    _Tab(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      route: '/home',
    ),
    _Tab(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Categories',
      route: '/categories',
    ),
    _Tab(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      label: 'Cart',
      route: '/cart',
    ),
    _Tab(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  int _indexFromLocation(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/categories')) return 1;
    if (loc.startsWith('/cart')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return _currentTabIndex;
  }

  void _onTabTapped(int i) {
    setState(() {
      // Build & cache the page only on first visit
      _cachedPages[i] ??= _pageBuilders[i]();
      _currentTabIndex = i;
    });
    context.go(_tabs[i].route);
  }

  @override
  Widget build(BuildContext context) {
    // Sync current index with router location (for deep links / back button)
    final routerIndex = _indexFromLocation(context);
    if (routerIndex != _currentTabIndex) {
      // Schedule so we don't setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentTabIndex = routerIndex);
      });
    }

    final index = _currentTabIndex;
    final cartCount = ref.watch(cartItemCountProvider);

    return PopScope(
      canPop: index == 0,
      onPopInvoked: (didPop) {
        if (!didPop && index != 0) {
          _onTabTapped(0);
        }
      },
      child: Scaffold(
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
          // Lazy IndexedStack: tabs are built only on first visit, then kept alive.
          child: IndexedStack(
            index: index,
            children: List.generate(
              _cachedPages.length,
              (i) => _cachedPages[i] ?? const SizedBox.shrink(),
            ),
          ),
        ),
        bottomNavigationBar: SizeTransition(
          sizeFactor: _hideAnimCtrl,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FloatingCartBar(),
              BottomNavigationBar(
                currentIndex: index,
                backgroundColor: Colors.white,
                selectedItemColor: AppTheme.primaryGreen,
                unselectedItemColor: AppTheme.textGrey,
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold),
                type: BottomNavigationBarType.fixed,
                onTap: _onTabTapped,
                items: List.generate(_tabs.length, (i) {
                  final tab = _tabs[i];
                  final isSelected = index == i;
                  final isCart = tab.route == '/cart';

                  Widget iconWidget;
                  if (tab.assetPath != null) {
                    iconWidget = Image.asset(
                      tab.assetPath!,
                      width: 24,
                      height: 24,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.textGrey,
                    );
                  } else {
                    iconWidget = Icon(
                      isSelected ? tab.activeIcon! : tab.icon!,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.textGrey,
                    );
                  }

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
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final IconData? icon;
  final IconData? activeIcon;
  final String? assetPath;
  final String label;
  final String route;
  const _Tab({
    this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  }) : assetPath = null;
}
