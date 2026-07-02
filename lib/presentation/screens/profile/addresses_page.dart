import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/domain/entities/address_entity.dart';
import 'package:veggie_mart/presentation/providers/address_controller.dart';

class AddressesPage extends ConsumerWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppTheme.textDark,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Addresses',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          if (state.isMutating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-edit-address'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text(
          'Add Address',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: state.addressesAsync.when(
        loading: () => const _AddressSkeleton(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load addresses',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref
                    .read(addressControllerProvider.notifier)
                    .fetchAddresses(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (addresses) => addresses.isEmpty
            ? _EmptyAddresses(onAdd: () => context.push('/add-edit-address'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _AddressCard(
                  address: addresses[index],
                  onEdit: () => context.push(
                    '/add-edit-address',
                    extra: addresses[index],
                  ),
                  onDelete: () =>
                      _confirmDelete(context, ref, addresses[index].id),
                  onSetDefault: () => ref
                      .read(addressControllerProvider.notifier)
                      .setDefaultAddress(addresses[index].id),
                ),
              ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        title: const Text(
          'Delete Address?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
            fontSize: 15,
          ),
        ),
        content: const Text(
          'This address will be permanently removed.',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await ref
                  .read(addressControllerProvider.notifier)
                  .deleteAddress(id);
              if (context.mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address deleted')),
                );
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Address Card ─────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  IconData get _labelIcon {
    switch (address.label.toLowerCase()) {
      case 'work':
        return Icons.work_outline_rounded;
      case 'other':
        return Icons.place_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  Color get _labelColor {
    switch (address.label.toLowerCase()) {
      case 'work':
        return const Color(0xFF6366F1);
      case 'other':
        return const Color(0xFF0EA5E9);
      default:
        return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault
              ? AppTheme.primaryGreen.withValues(alpha: 0.5)
              : const Color(0xFFE5E7EB),
          width: address.isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _labelColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_labelIcon, color: _labelColor, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppTheme.textGrey,
                    size: 18,
                  ),
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                    if (value == 'default') onSetDefault();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      height: 26,
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: AppTheme.textGrey,
                          ),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        height: 26,
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: AppTheme.primaryGreen,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Set as Default',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      height: 26,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Color(0xFFEF4444),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Address details
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address.mobile,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${address.addressLine}, ${address.city}, ${address.state} - ${address.pincode}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          // Container(
          //   decoration: const BoxDecoration(
          //     color: Color(0xFFF8F9FA),
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(12),
          //       bottomRight: Radius.circular(12),
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: TextButton.icon(
          //           onPressed: onEdit,
          //           icon: const Icon(Icons.edit_outlined, size: 14),
          //           label: const Text('Edit'),
          //           style: TextButton.styleFrom(
          //             padding: const EdgeInsets.symmetric(vertical: 8),
          //             foregroundColor: const Color(0xFF6366F1),
          //             textStyle: const TextStyle(
          //               fontSize: 12,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //         ),
          //       ),
          //       Container(width: 1, height: 16, color: const Color(0xFFE5E7EB)),
          //       if (!address.isDefault) ...[
          //         Expanded(
          //           child: TextButton.icon(
          //             onPressed: onSetDefault,
          //             icon: const Icon(Icons.check_circle_outline, size: 14),
          //             label: const Text('Set Default'),
          //             style: TextButton.styleFrom(
          //               padding: const EdgeInsets.symmetric(vertical: 8),
          //               foregroundColor: AppTheme.primaryGreen,
          //               textStyle: const TextStyle(
          //                 fontSize: 12,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ),
          //         ),
          //         Container(
          //           width: 1,
          //           height: 16,
          //           color: const Color(0xFFE5E7EB),
          //         ),
          //       ],
          //       Expanded(
          //         child: TextButton.icon(
          //           onPressed: onDelete,
          //           icon: const Icon(Icons.delete_outline, size: 14),
          //           label: const Text('Delete'),
          //           style: TextButton.styleFrom(
          //             padding: const EdgeInsets.symmetric(vertical: 8),
          //             foregroundColor: const Color(0xFFEF4444),
          //             textStyle: const TextStyle(
          //               fontSize: 12,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyAddresses extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyAddresses({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                size: 48,
                color: AppTheme.primaryGreen.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Saved Addresses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your delivery addresses to\nmake checkout faster.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Add New Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer Skeleton ──────────────────────────────────────────────────────────

class _AddressSkeleton extends StatefulWidget {
  const _AddressSkeleton();

  @override
  State<_AddressSkeleton> createState() => _AddressSkeletonState();
}

class _AddressSkeletonState extends State<_AddressSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
