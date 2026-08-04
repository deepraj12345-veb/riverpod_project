import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veg_king/core/network/network_provider.dart';
import 'package:veg_king/core/theme/app_theme.dart';

class NoInternetScreen extends ConsumerWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Illustration matching reference screenshot ──
                _buildCustomIllustration(),
                const SizedBox(height: 40),

                // ── Title ──
                const Text(
                  'Oops! We are not able to connect.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C2C2C),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Subtitle ──
                const Text(
                  'Please check your internet connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // ── Try Again Button styled with Veggie Mart AppTheme ──
                SizedBox(
                  width: 140,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(networkProvider.notifier).checkConnection();
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppTheme.primaryGreen.withValues(
                        alpha: 0.35,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 8),
                        Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Recreates the cute disconnected scene with Veggie Mart theme colors
  Widget _buildCustomIllustration() {
    return SizedBox(
      width: 280,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft misty clouds
          Positioned(
            left: 30,
            top: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F5).withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: 40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F5).withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Disconnected broken Wi-Fi cloud in the center gap
          const Positioned(
            top: 50,
            child: Icon(
              Icons.wifi_off_rounded,
              size: 46,
              color: Color(0xFFEF4444), // Red alert badge
            ),
          ),

          // ── Left Podium + Character (Green Veggie Item) ──
          Positioned(
            left: 20,
            bottom: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cute Green Character
                Container(
                  width: 58,
                  height: 95,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                      bottom: Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sad face
                      const Positioned(
                        top: 25,
                        child: Text(
                          '(•︵•)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      // Reaching arm right
                      Positioned(
                        right: 2,
                        top: 48,
                        child: Container(
                          width: 18,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Brown Podium
                Container(
                  width: 80,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F), // Rich wood brown
                    borderRadius: BorderRadius.circular(6),
                    border: const Border(
                      top: BorderSide(color: Color(0xFF92400E), width: 6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Right Podium + Character (Orange/Gold Item) ──
          Positioned(
            right: 20,
            bottom: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cute Gold/Orange Character
                Container(
                  width: 32,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                      bottom: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sad face
                      const Positioned(
                        top: 20,
                        child: Text(
                          '._.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      // Reaching arm left
                      Positioned(
                        left: 2,
                        top: 55,
                        child: Container(
                          width: 16,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Brown Podium
                Container(
                  width: 80,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    borderRadius: BorderRadius.circular(6),
                    border: const Border(
                      top: BorderSide(color: Color(0xFF92400E), width: 6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
