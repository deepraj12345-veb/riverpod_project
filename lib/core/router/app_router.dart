import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_project/core/providers/app_providers.dart';
import 'package:riverpod_project/features/auth/login_page.dart';
import 'package:riverpod_project/features/auth/signup_page.dart';
import 'package:riverpod_project/features/auth/otp_page.dart';
import 'package:riverpod_project/features/auth/forgot_password_page.dart';
import 'package:riverpod_project/features/splash/splash_page.dart';
import 'package:riverpod_project/features/shell/main_shell.dart';
import 'package:riverpod_project/features/home/home_page.dart';
import 'package:riverpod_project/features/product/product_detail_page.dart';
import 'package:riverpod_project/features/cart/cart_page.dart';
import 'package:riverpod_project/features/profile/profile_page.dart';
import 'package:riverpod_project/features/wishlist/wishlist_page.dart';

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
          GoRoute(
            path: '/product/:id',
            builder: (ctx, state) {
              final id = state.pathParameters['id']!;
              return ProductDetailPage(productId: id);
            },
          ),
          GoRoute(path: '/cart', builder: (ctx, state) => const CartPage()),
          GoRoute(
            path: '/profile',
            builder: (ctx, state) => const ProfilePage(),
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
