import 'dart:async';
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
    with TickerProviderStateMixin {
  late final AnimationController _chevronCtrl;
  late final Animation<double> _chevronAnim;
  late final AnimationController _riderCtrl;
  late final Animation<double> _riderAnim;
  Timer? _celebrationTimer;
  bool _wasFreeDelivery = false;
  bool _isCelebratingDelivery = false;

  @override
  void initState() {
    super.initState();
    _chevronCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _chevronAnim = Tween<double>(
      begin: 0.0,
      end: 5.0,
    ).animate(CurvedAnimation(parent: _chevronCtrl, curve: Curves.easeInOut));

    _riderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _riderAnim = CurvedAnimation(
      parent: _riderCtrl,
      curve: Curves.easeInOutCubic,
    );
  }

  void _triggerCelebration() {
    if (_isCelebratingDelivery) return;
    setState(() {
      _isCelebratingDelivery = true;
    });
    _riderCtrl.forward(from: 0.0);
    _celebrationTimer?.cancel();
    _celebrationTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _isCelebratingDelivery = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    _riderCtrl.dispose();
    _chevronCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    final loc = GoRouterState.of(context).matchedLocation;
    // Do not show on cart, checkout, profile, categories, subcategory, or subscription screens
    final showCartBar =
        cartCount > 0 &&
        loc != '/cart' &&
        loc != '/checkout' &&
        loc != '/categories' &&
        !loc.startsWith('/subcategory') &&
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

    if (isFreeDelivery && !_wasFreeDelivery && showCartBar) {
      _wasFreeDelivery = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _triggerCelebration();
      });
    } else if (!isFreeDelivery) {
      _wasFreeDelivery = false;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      clipBehavior: Clip.hardEdge,
      height: showCartBar ? null : 0.0,
      margin: showCartBar
          ? const EdgeInsets.fromLTRB(50, 3, 50, 6)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0C831F),
            Color(0xFF0C831F),
            Color.fromARGB(255, 0, 0, 0),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isCelebratingDelivery)
                    _buildRiderCelebration(cartSavings)
                  else ...[
                    // ── Top Section: Thumbnails + Item/Price + View Cart ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ── Line 1: Item Count + Current Price + Original Price ──
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      CustomText(
                                        '$cartCount ITEM${cartCount > 1 ? 'S' : ''}',
                                        style: const TextStyle(
                                          color: Color(
                                            0xFFFEF08A,
                                          ), // Instamart Gold
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        '•',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      CustomText(
                                        '₹${cartTotal.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      if (cartSavings > 0) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          '₹${totalOriginalPrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                            fontSize: 10.5,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // ── Line 2: Saved Money badge where price & discount used to be ──
                                if (cartSavings > 0) ...[
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5.5,
                                      vertical: 1.8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF15803D),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color(0xFF4ADE80),
                                        width: 0.6,
                                      ),
                                    ),
                                    child: CustomText(
                                      'SAVED ₹${cartSavings.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildViewCartButton(),
                        ],
                      ),
                    ),

                    // ── Bottom Section: Show ONLY when Free Delivery is NOT yet unlocked ──
                    if (!isFreeDelivery)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 2,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFEF08A),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4.5,
                              ),
                              color: Colors.black.withValues(alpha: 0.22),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delivery_dining_rounded,
                                    color: Color(0xFFFEF08A),
                                    size: 11,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: CustomText(
                                      'Add ₹${(199 - cartTotal).toStringAsFixed(0)} more to unlock FREE delivery',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildRiderCelebration(double cartSavings) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        // Caching the bike in a RepaintBoundary prevents bitmap & text repainting on every frame
        final cachedBikeWidget = RepaintBoundary(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 2),
              Image.asset(
                'assets/images/delivery_bike.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.two_wheeler_rounded,
                  color: Color(0xFFFEF08A),
                  size: 28,
                ),
              ),
            ],
          ),
        );

        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── Background Text: Phase 1 (moving) -> Phase 2 (saved amount) ──
              AnimatedBuilder(
                animation: _riderCtrl,
                builder: (ctx, _) {
                  final isMoving =
                      _riderCtrl.isAnimating || _riderCtrl.value < 1.0;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isMoving
                        ? const Row(
                            key: ValueKey('phase1'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.electric_bolt_rounded,
                                color: Color(0xFFFEF08A),
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              CustomText(
                                'You unlocked FREE DELIVERY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            key: const ValueKey('phase2'),
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CustomText(
                                'You unlocked FREE DELIVERY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              CustomText(
                                cartSavings > 0
                                    ? 'SAVED ₹${cartSavings.toStringAsFixed(0)}'
                                    : 'SAVED ₹25',
                                style: const TextStyle(
                                  color: Color(0xFFFEF08A),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),

              // ── Super smooth GPU-accelerated bike movement ──
              AnimatedBuilder(
                animation: _riderAnim,
                child:
                    cachedBikeWidget, // Re-uses GPU texture without repainting
                builder: (ctx, child) {
                  if (!_riderCtrl.isAnimating && _riderCtrl.value >= 1.0) {
                    return const SizedBox.shrink();
                  }
                  final leftPos =
                      -45.0 + (_riderAnim.value * (maxWidth + 55.0));
                  return Positioned(left: leftPos, child: child!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewCartButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _chevronAnim,
          builder: (ctx, child) {
            return Transform.translate(
              offset: Offset(_chevronAnim.value, 0),
              child: child,
            );
          },
          child: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnails(List<CartItemEntity> items) {
    final count = items.length.clamp(0, 3);
    final hasMore = items.length > 3;
    final totalCircles = hasMore ? count + 1 : count;
    final width = totalCircles == 0 ? 0.0 : (26.0 + (totalCircles - 1) * 18.0);

    return SizedBox(
      key: ValueKey(items.map((e) => e.product.id).join(',')),
      width: width,
      height: 26,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < count; i++)
            Positioned(
              left: i * 18.0,
              child: Container(
                width: 26,
                height: 26,
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
              left: count * 18.0,
              child: Container(
                width: 26,
                height: 26,
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
