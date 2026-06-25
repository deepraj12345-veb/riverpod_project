import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to login after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightGreen,
              AppTheme.primaryGreen,
              AppTheme.deepGreen,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon - mimicking the two leaves
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.lightGreen,
                      AppTheme.primaryGreen,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200',
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (ctx, url, err) => const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Text "VeggieMart" styled like "GLOWGREEN"
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'VEGGIE',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'MART',
                      style: TextStyle(color: AppTheme.deepGreen),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

