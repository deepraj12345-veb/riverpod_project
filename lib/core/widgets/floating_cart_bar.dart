import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/widgets/custom_network_image.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/presentation/providers/cart_controller.dart';
import 'package:veggie_mart/domain/entities/cart_item_entity.dart';

class FloatingCartBar extends ConsumerStatefulWidget {
  static final GlobalKey cartKey = GlobalKey();
  const FloatingCartBar({super.key});

  @override
  ConsumerState<FloatingCartBar> createState() => _FloatingCartBarState();
}

class _FloatingCartBarState extends ConsumerState<FloatingCartBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _chevronCtrl;
  late final Animation<double> _chevronAnim;

  @override
  void initState() {
    super.initState();
    _chevronCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    ); // Removed repeat to prevent continuous log print
    _chevronAnim = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _chevronCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _chevronCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    final loc = GoRouterState.of(context).matchedLocation;
    // Do not show on cart, checkout, profile, or subscription screens
    final showCartBar = cartCount > 0 &&
        loc != '/cart' &&
        loc != '/checkout' &&
        !loc.startsWith('/profile') &&
        !loc.startsWith('/subscription');

    final cartSavings = cartItems.fold<double>(0.0, (sum, item) {
      final savings = item.product.originalPrice - item.product.price;
      return sum + (savings > 0 ? savings * item.quantity : 0.0);
    });

    final totalOriginalPrice = cartItems.fold<double>(0.0, (sum, item) {
      return sum + (item.product.originalPrice * item.quantity);
    });

    final isFreeDelivery = cartTotal >= 199;
    final progress = (cartTotal / 199).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      clipBehavior: Clip.hardEdge,
      height: showCartBar ? 82.0 : 0.0,
      margin: showCartBar
          ? const EdgeInsets.fromLTRB(14, 6, 14, 10)
          : EdgeInsets.zero,
      padding: showCartBar
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0C831F), // Darker forest green
            Color(0xFF15993B), // Brighter emerald green accent
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: showCartBar
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: showCartBar
          ? InkWell(
              onTap: () => context.go('/cart'),
              borderRadius: BorderRadius.circular(14),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  height: 62, // Fixed inner height to prevent overflow during shrink animation
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top section: thumbnails, pricing details, View Cart capsule
                  Row(
                    children: [
                      // Animated overlapping product thumbnails
                      AnimatedSwitcher(
                        key: FloatingCartBar.cartKey,
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: _buildThumbnails(cartItems),
                      ),
                      const SizedBox(width: 10),
                      // Pricing and item info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  CustomText(
                                    '$cartCount item${cartCount > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    '|',
                                    style: TextStyle(
                                        color: Colors.white38, fontSize: 11),
                                  ),
                                  const SizedBox(width: 5),
                                  CustomText(
                                    '₹${cartTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (cartSavings > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '₹${totalOriginalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 10.5,
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (cartSavings > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_offer_rounded,
                                        color: Color(0xFF86EFAC),
                                        size: 8,
                                      ),
                                      const SizedBox(width: 3),
                                      CustomText(
                                        'Saved ₹${cartSavings.toStringAsFixed(0)}!',
                                        style: const TextStyle(
                                          color: Color(0xFF86EFAC),
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // View Cart white pill/capsule button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomText(
                              'View Cart',
                              style: TextStyle(
                                color: Color(0xFF0C831F),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 2),
                            AnimatedBuilder(
                              animation: _chevronAnim,
                              builder: (ctx, child) {
                                return Transform.translate(
                                  offset: Offset(_chevronAnim.value, 0),
                                  child: child,
                                );
                              },
                              child: const Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: Color(0xFF0C831F),
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Bottom section: Progress indicator towards Free Delivery
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isFreeDelivery
                                ? Icons.check_circle_rounded
                                : Icons.delivery_dining_rounded,
                            color: const Color.fromARGB(255, 255, 255, 255),
                            size: 10.5,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: CustomText(
                              isFreeDelivery
                                  ? 'FREE delivery applied to this order!'
                                  : 'Add ₹${(199 - cartTotal).toStringAsFixed(0)} more for FREE delivery',
                              style: TextStyle(
                                color: isFreeDelivery
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.85),
                                fontSize: 8.5,
                                fontWeight: isFreeDelivery
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(1),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 2,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF86EFAC)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildThumbnails(List<CartItemEntity> items) {
    final count = items.length.clamp(0, 3);
    final hasMore = items.length > 3;
    final totalCircles = hasMore ? count + 1 : count;
    final width = totalCircles == 0 ? 0.0 : (30.0 + (totalCircles - 1) * 20.0);

    return SizedBox(
      key: ValueKey(items.map((e) => e.product.id).join(',')),
      width: width,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < count; i++)
            Positioned(
              left: i * 20.0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomNetworkImage(
                    imageUrl: items[i].product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          if (hasMore)
            Positioned(
              left: count * 20.0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1F2937),
                  border: Border.all(color: Colors.white, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '+${items.length - 3}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FlyToCartOverlay {
  static void run({
    required BuildContext context,
    required String imageUrl,
    required Offset startPos,
    required Offset endPos,
    required Size startSize,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _FlyingImageWidget(
          imageUrl: imageUrl,
          startPos: startPos,
          endPos: endPos,
          startSize: startSize,
          onComplete: () {
            entry.remove();
          },
        );
      },
    );

    overlayState.insert(entry);
  }
}

class _FlyingImageWidget extends StatefulWidget {
  final String imageUrl;
  final Offset startPos;
  final Offset endPos;
  final Size startSize;
  final VoidCallback onComplete;

  const _FlyingImageWidget({
    required this.imageUrl,
    required this.startPos,
    required this.endPos,
    required this.startSize,
    required this.onComplete,
  });

  @override
  State<_FlyingImageWidget> createState() => _FlyingImageWidgetState();
}

class _FlyingImageWidgetState extends State<_FlyingImageWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        final x =
            widget.startPos.dx + (widget.endPos.dx - widget.startPos.dx) * t;
        final y =
            widget.startPos.dy + (widget.endPos.dy - widget.startPos.dy) * t;
        // Parabolic arc peaking upward (negative Y coordinate shift)
        final arc = -100.0 * (t * (1.0 - t) * 4.0);

        final width =
            widget.startSize.width + (30.0 - widget.startSize.width) * t;
        final height =
            widget.startSize.height + (30.0 - widget.startSize.height) * t;
        final rotation = t * 2.0 * 3.14159; // 1 spin

        return Positioned(
          left: x,
          top: y + arc,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: (1.0 - t).clamp(0.0, 1.0),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CustomNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
