import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:veggie_mart/core/widgets/custom_network_image.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/presentation/providers/auth_provider.dart';
import 'package:veggie_mart/presentation/providers/cart_controller.dart';
import 'package:veggie_mart/presentation/providers/profile_controller.dart';
import 'package:veggie_mart/presentation/providers/orders_controller.dart';
import 'package:veggie_mart/presentation/providers/dashboard_provider.dart';
import 'package:veggie_mart/presentation/providers/address_controller.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/core/providers/app_providers.dart'
    hide cartItemCountProvider, productsProvider;
import 'package:veggie_mart/presentation/providers/wishlist_controller.dart';

// ignore_for_file: unused_import

// ── Clean palette for profile cards (distinct, non-green) ──────────────────
class _Palette {
  static const Color ordersIcon = Color(0xFF6366F1);
  static const Color ordersBg = Color(0xFFEEF2FF);
  static const Color wishlistIcon = Color(0xFFEC4899);
  static const Color wishlistBg = Color(0xFFFDF2F8);
  static const Color cartIcon = Color(0xFFF59E0B);
  static const Color cartBg = Color(0xFFFFFBEB);
  static const Color walletIcon = Color(0xFF8B5CF6);
  static const Color walletBg = Color(0xFFF5F3FF);
  static const Color addressIcon = Color(0xFF0EA5E9);
  static const Color addressBg = Color(0xFFF0F9FF);
  static const Color offersIcon = Color(0xFFEF4444);
  static const Color offersBg = Color(0xFFFEF2F2);
  // Menu icons
  static const Color subIcon = Color(0xFFF59E0B);
  static const Color subBg = Color(0xFFFFFBEB);
  static const Color locationIcon = Color(0xFF0EA5E9);
  static const Color locationBg = Color(0xFFF0F9FF);
  static const Color paymentIcon = Color(0xFF10B981);
  static const Color paymentBg = Color(0xFFECFDF5);
  static const Color historyIcon = Color(0xFF8B5CF6);
  static const Color historyBg = Color(0xFFF5F3FF);
  static const Color notifIcon = Color(0xFFEC4899);
  static const Color notifBg = Color(0xFFFDF2F8);
  static const Color helpIcon = Color(0xFF64748B);
  static const Color helpBg = Color(0xFFF8FAFC);
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final user = ref.watch(userProvider);
    final isPremium = ref.watch(isPremiumUserProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final wishlistCount = ref.watch(wishlistProvider).length;
    final dashboardAsync = ref.watch(dashboardProvider);
    final addressCount = ref.watch(addressCountProvider);

    final ordersCount = dashboardAsync.maybeWhen(
      data: (d) => d.totalOrders,
      orElse: () => ref.watch(ordersProvider).length,
    );
    final savedAddresses = dashboardAsync.maybeWhen(
      data: (d) => d.savedAddresses,
      orElse: () => 0,
    );
    // Wallet balance from profile API
    final walletBalance = profileState.userAsync.maybeWhen(
      data: (u) => u.walletBalance,
      orElse: () => 0.0,
    );
    // Loading / error state from profile fetch
    final isProfileLoading = profileState.userAsync is AsyncLoading;
    final profileError = profileState.userAsync.maybeWhen(
      error: (e, _) => e.toString(),
      orElse: () => null,
    );

    return Scaffold(
      body: isProfileLoading
          ? const _ProfileSkeleton()
          : profileError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Failed to load profile',
                    style: TextStyle(color: AppTheme.textGrey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(profileControllerProvider.notifier)
                        .fetchProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // ── Compact AppBar ─────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0.5,
                  shadowColor: Colors.black12,
                  title: const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppTheme.textDark,
                        size: 22,
                      ),
                      onPressed: () => context.push('/edit-profile'),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // ── Profile header card ─────────────────────────────────
                      _ProfileCard(user: user, isPremium: isPremium),

                      const SizedBox(height: 12),

                      // ── Stats grid ─────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.receipt_long_rounded,
                                    label: 'Orders',
                                    value: '$ordersCount',
                                    iconColor: _Palette.ordersIcon,
                                    bgColor: _Palette.ordersBg,
                                    onTap: () => context.push('/orders'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.favorite_rounded,
                                    label: 'Wishlist',
                                    value: '$wishlistCount',
                                    iconColor: _Palette.wishlistIcon,
                                    bgColor: _Palette.wishlistBg,
                                    onTap: () => context.push('/wishlist'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.shopping_cart_rounded,
                                    label: 'Cart',
                                    value: '$cartCount',
                                    iconColor: _Palette.cartIcon,
                                    bgColor: _Palette.cartBg,
                                    onTap: () => context.go('/cart'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.account_balance_wallet_rounded,
                                    label: 'Wallet',
                                    value:
                                        'Rs.${walletBalance.toStringAsFixed(0)}',
                                    iconColor: _Palette.walletIcon,
                                    bgColor: _Palette.walletBg,
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.location_on_rounded,
                                    label: 'Addresses',
                                    value: '$addressCount',
                                    iconColor: _Palette.addressIcon,
                                    bgColor: _Palette.addressBg,
                                    onTap: () => context.push('/addresses'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.local_offer_rounded,
                                    label: 'Offers',
                                    value: 'Gift',
                                    iconColor: _Palette.offersIcon,
                                    bgColor: _Palette.offersBg,
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Section label ─────────────────────────────────────
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ACCOUNT SETTINGS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textGrey,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Menu list ─────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            children: [
                              _MenuRow(
                                icon: Icons.star_rounded,
                                title: 'Subscription',
                                subtitle: isPremium
                                    ? 'Premium Active'
                                    : 'Upgrade to Premium',
                                iconColor: _Palette.subIcon,
                                bgColor: _Palette.subBg,
                                showDivider: true,
                                onTap: () => context.push('/subscription'),
                              ),

                              _MenuRow(
                                icon: Icons.location_on_outlined,
                                title: 'My Addresses',
                                subtitle: addressCount == 0
                                    ? 'Add your delivery address'
                                    : '$addressCount saved address${addressCount == 1 ? '' : 'es'}',
                                iconColor: _Palette.locationIcon,
                                bgColor: _Palette.locationBg,
                                showDivider: true,
                                onTap: () => context.push('/addresses'),
                              ),
                              _MenuRow(
                                icon: Icons.payment_outlined,
                                title: 'Payment Methods',
                                subtitle: 'UPI, Cards, Wallets',
                                iconColor: _Palette.paymentIcon,
                                bgColor: _Palette.paymentBg,
                                showDivider: true,
                                onTap: () {},
                              ),
                              _MenuRow(
                                icon: Icons.receipt_long_outlined,
                                title: 'Order History',
                                subtitle: '$ordersCount orders completed',
                                iconColor: _Palette.historyIcon,
                                bgColor: _Palette.historyBg,
                                showDivider: true,
                                onTap: () => context.go('/orders'),
                              ),
                              _MenuRow(
                                icon: Icons.notifications_outlined,
                                title: 'Notifications',
                                subtitle: 'Push notifications enabled',
                                iconColor: _Palette.notifIcon,
                                bgColor: _Palette.notifBg,
                                showDivider: true,
                                onTap: () {},
                              ),
                              _MenuRow(
                                icon: Icons.help_outline_rounded,
                                title: 'Help & Support',
                                subtitle: 'FAQs, contact us',
                                iconColor: _Palette.helpIcon,
                                bgColor: _Palette.helpBg,
                                showDivider: false,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Sign Out ──────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          onTap: () => _confirmSignOut(context, ref),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.35),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 19,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Fresh Veggie Mart v1.0.0  -  Via Two Wheels',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out of Fresh Veggie Mart?',
          style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile header card ──────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final dynamic user;
  final bool isPremium;

  const _ProfileCard({required this.user, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEEF2FF),
                  border: Border.all(color: AppTheme.primaryGreen, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF6366F1),
                    size: 38,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Name, email, badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.push('/subscription'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPremium
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: isPremium
                              ? const Color(0xFFF59E0B)
                              : AppTheme.textGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPremium ? 'Premium Member' : 'Upgrade to Premium',
                          style: TextStyle(
                            color: isPremium
                                ? const Color(0xFFD97706)
                                : AppTheme.textGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

// ── Stat card (3 per row) ────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menu row ──────────────────────────────────────────────────────────────────

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color bgColor;
  final bool showDivider;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.bgColor,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFD1D5DB),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 0,
            color: Color(0xFFF3F4F6),
          ),
      ],
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 100,
                              height: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 120,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildSkeletonCard()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildSkeletonCard()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildSkeletonCard()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildSkeletonCard()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildSkeletonCard()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildSkeletonCard()),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(width: 120, height: 12, color: Colors.white),
                ),
                const SizedBox(height: 8),

                // Menu List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: List.generate(
                        5,
                        (index) => _buildSkeletonMenuRow(),
                      ),
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

  Widget _buildSkeletonCard() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildSkeletonMenuRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(width: 100, height: 10, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
