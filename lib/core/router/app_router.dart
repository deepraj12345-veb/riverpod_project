import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/presentation/providers/auth_provider.dart';
import 'package:veggie_mart/presentation/providers/auth_state.dart';
import 'package:veggie_mart/presentation/screens/auth/login_page.dart';
import 'package:veggie_mart/presentation/screens/auth/signup_page.dart';
import 'package:veggie_mart/presentation/screens/auth/otp_page.dart';
import 'package:veggie_mart/presentation/screens/auth/forgot_password_page.dart';
import 'package:veggie_mart/presentation/screens/splash/splash_splash_page.dart';
import 'package:veggie_mart/presentation/screens/shell/main_shell.dart';
import 'package:veggie_mart/presentation/screens/home/home_page.dart';
import 'package:veggie_mart/presentation/screens/product/product_detail_page.dart';
import 'package:veggie_mart/presentation/screens/cart/cart_page.dart';
import 'package:veggie_mart/presentation/screens/profile/profile_page.dart';
import 'package:veggie_mart/presentation/screens/profile/subscription_page.dart';
import 'package:veggie_mart/presentation/screens/wishlist/wishlist_page.dart';
import 'package:veggie_mart/presentation/screens/categories/categories_page.dart';
import 'package:veggie_mart/presentation/screens/categories/subcategory_page.dart';
import 'package:veggie_mart/presentation/screens/orders/order_again_page.dart';
import 'package:veggie_mart/presentation/screens/orders/orders_list_page.dart';
import 'package:veggie_mart/presentation/screens/orders/order_detail_page.dart';
import 'package:veggie_mart/presentation/screens/checkout/checkout_page.dart';
import 'package:veggie_mart/presentation/screens/home/search_page.dart';
import 'package:flutter/foundation.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ValueNotifier<int>(0);
  
  ref.listen(authProvider, (previous, next) {
    if (previous != next) {
      routerNotifier.value++;
    }
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      // Allow SplashPage to show and handle its own timer
      if (state.matchedLocation == '/') return null;

      final authState = ref.read(authProvider);
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      
      final isAuthRoute =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation.startsWith('/otp');

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (ctx, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (ctx, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (ctx, state) => const SignupPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (ctx, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/otp',
        builder: (ctx, state) {
          final phone = state.extra as String? ?? '';
          return OtpPage(phone: phone);
        },
      ),
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (ctx, state) => const HomePage()),
          GoRoute(path: '/search', builder: (ctx, state) => const SearchPage()),
          GoRoute(
            path: '/product/:id',
            builder: (ctx, state) {
              final id = state.pathParameters['id']!;
              return ProductDetailPage(productId: id);
            },
          ),
          GoRoute(path: '/cart', builder: (ctx, state) => const CartPage()),
          GoRoute(
            path: '/checkout',
            builder: (ctx, state) {
              final appliedDiscount = state.extra as double? ?? 0.0;
              return CheckoutPage(appliedDiscount: appliedDiscount);
            },
          ),
          GoRoute(
            path: '/categories',
            builder: (ctx, state) => const CategoriesPage(),
          ),
          GoRoute(
            path: '/subcategory',
            builder: (ctx, state) {
              final categoryName = state.extra as String? ?? 'All';
              return SubcategoryPage(categoryName: categoryName);
            },
          ),
          GoRoute(
            path: '/order-again',
            builder: (ctx, state) => const OrderAgainPage(),
          ),
          GoRoute(
            path: '/orders',
            builder: (ctx, state) => const OrdersListPage(),
          ),
          GoRoute(
            path: '/order/:id',
            builder: (ctx, state) {
              final id = state.pathParameters['id']!;
              return OrderDetailPage(orderId: id);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (ctx, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/subscription',
            builder: (ctx, state) => const SubscriptionPage(),
          ),
          GoRoute(
            path: '/wishlist',
            builder: (ctx, state) => const WishlistPage(),
          ),
        ],
      ),
    ],
  );
});
