import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veg_king/core/theme/app_theme.dart';
import 'package:veg_king/domain/entities/address_entity.dart';
import 'package:veg_king/presentation/providers/address_controller.dart';
import 'package:veg_king/core/utils/location_helper.dart';

void showAddressBottomSheet(
  BuildContext context,
  WidgetRef ref, {
  AddressEntity? selectedAddress,
  Function(AddressEntity)? onSelect,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Consumer(
        builder: (ctx, ref, _) {
          final addressState = ref.watch(addressControllerProvider);
          final addresses = addressState.addressesAsync.valueOrNull ?? [];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Delivery Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Empty state
                  if (addresses.isEmpty) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 52,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No saved addresses',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add a delivery address to proceed',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const _CurrentLocationButton(),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.push('/add-edit-address').then((_) {
                                  ref
                                      .read(addressControllerProvider.notifier)
                                      .fetchAddresses();
                                });
                              },
                              icon: const Icon(Icons.add_location_alt_rounded),
                              label: const Text('Add New Address'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]
                  // Address list
                  else ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.55,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final address = addresses[i];
                          final isSelected =
                              selectedAddress?.id == address.id ||
                              address.isDefault;
                          return InkWell(
                            onTap: () {
                              ref
                                  .read(addressControllerProvider.notifier)
                                  .setDefaultAddress(address.id);
                              if (onSelect != null) {
                                onSelect(address);
                              }
                              Navigator.pop(ctx);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryGreen.withValues(
                                        alpha: 0.05,
                                      )
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryGreen
                                      : AppTheme.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? AppTheme.primaryGreen
                                        : AppTheme.textGrey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              address.label,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                            if (address.isDefault) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryGreen
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                  'Default',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppTheme.primaryGreen,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          address.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${address.addressLine}, ${address.city}, ${address.state} - ${address.pincode}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textGrey,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _CurrentLocationButton(),
                    const SizedBox(height: 8),
                    // Add new address button
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/add-edit-address').then((_) {
                          ref
                              .read(addressControllerProvider.notifier)
                              .fetchAddresses();
                        });
                      },
                      icon: const Icon(
                        Icons.add_location_alt_outlined,
                        size: 18,
                      ),
                      label: const Text('Add New Address'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _CurrentLocationButton extends StatefulWidget {
  const _CurrentLocationButton();

  @override
  State<_CurrentLocationButton> createState() => _CurrentLocationButtonState();
}

class _CurrentLocationButtonState extends State<_CurrentLocationButton> {
  bool _loading = false;

  Future<void> _fetchAndGo() async {
    setState(() => _loading = true);
    try {
      final loc = await LocationHelper.fetchCurrentLocation();
      if (loc != null && mounted) {
        Navigator.pop(context);
        context.push(
          '/add-edit-address',
          extra: AddressEntity(
            id: '',
            label: 'Home',
            name: '',
            mobile: '',
            addressLine: loc.addressLine,
            city: loc.city,
            state: loc.state,
            pincode: loc.pincode,
            isDefault: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _loading ? null : _fetchAndGo,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryGreen,
                ),
              )
            else
              const Icon(
                Icons.my_location_rounded,
                color: AppTheme.primaryGreen,
                size: 22,
              ),
            const SizedBox(width: 12),
            Text(
              _loading ? 'Detecting Location...' : 'Use Current Location',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
