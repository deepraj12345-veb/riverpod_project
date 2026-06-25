import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/widgets/custom_network_image.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/features/auth/presentation/controllers/login_controller.dart';
import 'package:veggie_mart/features/cart/presentation/controllers/cart_controller.dart';
import 'package:veggie_mart/features/home/presentation/controllers/home_controller.dart';
import 'package:veggie_mart/features/profile/presentation/controllers/profile_controller.dart';
import 'package:veggie_mart/features/orders/presentation/controllers/orders_controller.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/core/providers/app_providers.dart' hide cartItemCountProvider, productsProvider, authProvider;

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isPremium = ref.watch(isPremiumUserProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final wishlistCount =
        ref.watch(productsProvider).where((p) => p.isFavorite).length;
    final ordersCount = ref.watch(ordersProvider).length;

    final menuItems = [
      _MenuItem(
        icon: Icons.star_rounded,
        title: 'Subscription Details',
        subtitle: isPremium ? 'Premium Active' : 'Upgrade to Premium',
        bgColor: AppTheme.cardMint,
        iconColor: AppTheme.primaryGreen,
      ),
      const _MenuItem(
        icon: Icons.person_outline_rounded,
        title: 'Edit Profile',
        subtitle: 'Update your personal info',
        bgColor: AppTheme.cardMint,
        iconColor: AppTheme.primaryGreen,
      ),
      _MenuItem(
        icon: Icons.location_on_outlined,
        title: 'My Addresses',
        subtitle: user.address,
        bgColor: AppTheme.cardLavender,
        iconColor: AppTheme.emeraldGreen,
      ),
      const _MenuItem(
        icon: Icons.payment_outlined,
        title: 'Payment Methods',
        subtitle: 'UPI, Cards, Wallets',
        bgColor: AppTheme.cardYellow,
        iconColor: AppTheme.deepGreen,
      ),
      _MenuItem(
        icon: Icons.receipt_long_outlined,
        title: 'Order History',
        subtitle: '$ordersCount orders completed',
        bgColor: AppTheme.cardPeach,
        iconColor: AppTheme.primaryGreen,
      ),
      const _MenuItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Push notifications enabled',
        bgColor: AppTheme.cardLightBlue,
        iconColor: AppTheme.emeraldGreen,
      ),
      const _MenuItem(
        icon: Icons.help_outline_rounded,
        title: 'Help & Support',
        subtitle: 'FAQs, contact us',
        bgColor: AppTheme.cardSkyBlue,
        iconColor: AppTheme.primaryGreen,
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Profile header ───────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.bgWhite,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: AppTheme.textDark),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.bgWhite,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryGreen,
                              width: 2.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: ClipOval(
                            child: CustomNetworkImage(
                              imageUrl: user.avatarUrl,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                color: AppTheme.cardMint,
                                child: const Icon(Icons.person_rounded,
                                    color: AppTheme.primaryGreen, size: 40),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_rounded,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomText(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        context.push('/subscription');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isPremium ? AppTheme.cardMint : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPremium ? AppTheme.primaryGreen.withValues(alpha: 0.3) : Colors.grey.shade300,
                          ),
                        ),
                        child: CustomText(
                          isPremium ? '⭐ Premium Member' : '⭐ Upgrade to Premium',
                          style: TextStyle(
                            color: isPremium ? AppTheme.primaryGreen : Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick action cards
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.receipt_long_rounded,
                          label: 'Orders',
                          value: '$ordersCount',
                          subtitle: 'completed',
                          bgColor: AppTheme.cardMint,
                          iconColor: AppTheme.primaryGreen,
                          onTap: () => context.push('/orders'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.favorite_rounded,
                          label: 'Wishlist',
                          value: '$wishlistCount',
                          subtitle: 'saved items',
                          bgColor: AppTheme.cardRose,
                          iconColor: AppTheme.accentRed,
                          onTap: () => context.push('/wishlist'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.shopping_cart_rounded,
                          label: 'Cart',
                          value: '$cartCount',
                          subtitle: 'items added',
                          bgColor: AppTheme.cardYellow,
                          iconColor: AppTheme.deepGreen,
                          onTap: () => context.go('/cart'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Menu items
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      children: List.generate(menuItems.length, (i) {
                        final item = menuItems[i];
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                if (item.title == 'Subscription Details') {
                                  context.push('/subscription');
                                } else if (item.title == 'Order History') {
                                  context.go('/orders');
                                }
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: item.bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.iconColor,
                                  size: 21,
                                ),
                              ),
                              title: CustomText(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              subtitle: CustomText(
                                item.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textGrey,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: AppTheme.textLight,
                                size: 22,
                              ),
                            ),
                            if (i < menuItems.length - 1)
                              const Divider(
                                height: 1,
                                indent: 72,
                                color: AppTheme.borderColor,
                              ),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sign Out
                  GestureDetector(
                    onTap: () => _confirmSignOut(context, ref),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.accentRed.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: AppTheme.accentRed, size: 20),
                          SizedBox(width: 8),
                          CustomText(
                            'Sign Out',
                            style: TextStyle(
                              color: AppTheme.accentRed,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  const CustomText(
                    'Fresh Veggie Mart v1.0.0  •  Via Two Wheels 🛵',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const CustomText('Sign Out?',
            style: TextStyle(color: AppTheme.textDark)),
        content: const CustomText(
          'Are you sure you want to sign out of Fresh Veggie Mart?',
          style: TextStyle(color: AppTheme.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const CustomText('Cancel',
                style: TextStyle(color: AppTheme.textGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const CustomText('Sign Out',
                style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
  });
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.bgWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                CustomText(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomText(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            CustomText(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

