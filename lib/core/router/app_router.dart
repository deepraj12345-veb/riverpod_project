import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/features/auth/presentation/controllers/login_controller.dart';
import 'package:veggie_mart/features/auth/presentation/pages/login_page.dart';
import 'package:veggie_mart/features/auth/presentation/pages/signup_page.dart';
import 'package:veggie_mart/features/auth/presentation/pages/otp_page.dart';
import 'package:veggie_mart/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:veggie_mart/features/splash/presentation/pages/splash_page.dart';
import 'package:veggie_mart/features/shell/presentation/pages/main_shell.dart';
import 'package:veggie_mart/features/home/presentation/pages/home_page.dart';
import 'package:veggie_mart/features/product/presentation/pages/product_detail_page.dart';
import 'package:veggie_mart/features/cart/presentation/pages/cart_page.dart';
import 'package:veggie_mart/features/profile/presentation/pages/profile_page.dart';
import 'package:veggie_mart/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:veggie_mart/features/categories/presentation/pages/categories_page.dart';
import 'package:veggie_mart/features/categories/presentation/pages/subcategory_page.dart';
import 'package:veggie_mart/features/orders/presentation/pages/order_again_page.dart';
import 'package:veggie_mart/features/orders/presentation/pages/orders_list_page.dart';
import 'package:veggie_mart/features/orders/presentation/pages/order_detail_page.dart';
import 'package:veggie_mart/features/checkout/presentation/pages/checkout_page.dart';
import 'package:veggie_mart/features/home/presentation/pages/search_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState == AuthState.authenticated;
      final isAuthRoute = state.matchedLocation == '/' ||
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
      GoRoute(path: '/forgot-password', builder: (ctx, state) => const ForgotPasswordPage()),
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
          GoRoute(path: '/categories', builder: (ctx, state) => const CategoriesPage()),
          GoRoute(
            path: '/subcategory',
            builder: (ctx, state) {
              final categoryName = state.extra as String? ?? 'All';
              return SubcategoryPage(categoryName: categoryName);
            },
          ),
          GoRoute(path: '/order-again', builder: (ctx, state) => const OrderAgainPage()),
          GoRoute(path: '/orders', builder: (ctx, state) => const OrdersListPage()),
          GoRoute(
            path: '/order/:id',
            builder: (ctx, state) {
              final id = state.pathParameters['id']!;
              return OrderDetailPage(orderId: id);
            },
          ),
          GoRoute(path: '/profile', builder: (ctx, state) => const ProfilePage()),
          GoRoute(path: '/wishlist', builder: (ctx, state) => const WishlistPage()),
        ],
      ),
    ],
  );
});

