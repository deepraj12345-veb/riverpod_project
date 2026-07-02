import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/domain/entities/address_entity.dart';
import 'package:veggie_mart/presentation/providers/address_controller.dart';

class AddEditAddressPage extends ConsumerStatefulWidget {
  final AddressEntity? address; // null = Add mode, non-null = Edit mode

  const AddEditAddressPage({super.key, this.address});

  @override
  ConsumerState<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends ConsumerState<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _addressLineCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  late String _selectedLabel;
  late bool _isDefault;

  bool get _isEdit => widget.address != null;

  static const List<String> _labels = ['Home', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _mobileCtrl = TextEditingController(text: a?.mobile ?? '');
    _addressLineCtrl = TextEditingController(text: a?.addressLine ?? '');
    _cityCtrl = TextEditingController(text: a?.city ?? '');
    _stateCtrl = TextEditingController(text: a?.state ?? '');
    _pincodeCtrl = TextEditingController(text: a?.pincode ?? '');
    _selectedLabel = a?.label ?? 'Home';
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _addressLineCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(addressControllerProvider.notifier);
    bool ok;

    if (_isEdit) {
      ok = await notifier.updateAddress(widget.address!.id, {
        'label': _selectedLabel,
        'name': _nameCtrl.text.trim(),
        'mobile': _mobileCtrl.text.trim(),
        'address_line': _addressLineCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),
        'is_default': _isDefault,
      });
    } else {
      ok = await notifier.addAddress(
        AddressEntity(
          id: '',
          label: _selectedLabel,
          name: _nameCtrl.text.trim(),
          mobile: _mobileCtrl.text.trim(),
          addressLine: _addressLineCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          state: _stateCtrl.text.trim(),
          pincode: _pincodeCtrl.text.trim(),
          isDefault: _isDefault,
        ),
      );
    }

    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Address updated!' : 'Address added!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        context.pop();
      } else {
        final err =
            ref.read(addressControllerProvider).mutationError ??
            'Error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMutating = ref.watch(addressControllerProvider).isMutating;

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
        title: Text(
          _isEdit ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Label chips ──────────────────────────────────────────────
              const _SectionLabel('Address Label'),
              const SizedBox(height: 8),
              Row(
                children: _labels.map((label) {
                  final selected = _selectedLabel == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedLabel = label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryGreen
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryGreen
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: selected ? Colors.white : AppTheme.textGrey,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // ── Personal details ─────────────────────────────────────────
              const _SectionLabel('Personal Details'),
              const SizedBox(height: 8),
              _FormCard(
                children: [
                  _Field(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Name is required' : null,
                  ),
                  const _Divider(),
                  _Field(
                    controller: _mobileCtrl,
                    label: 'Mobile Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Mobile is required';
                      if (v.length != 10) return 'Enter valid 10-digit number';
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Address details ──────────────────────────────────────────
              const _SectionLabel('Delivery Address'),
              const SizedBox(height: 8),
              _FormCard(
                children: [
                  _Field(
                    controller: _addressLineCtrl,
                    label: 'House No, Street, Area',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Address is required' : null,
                  ),
                  const _Divider(),
                  _Field(
                    controller: _cityCtrl,
                    label: 'City',
                    icon: Icons.location_city_outlined,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'City is required' : null,
                  ),
                  const _Divider(),
                  _Field(
                    controller: _stateCtrl,
                    label: 'State',
                    icon: Icons.map_outlined,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'State is required' : null,
                  ),
                  const _Divider(),
                  _Field(
                    controller: _pincodeCtrl,
                    label: 'Pincode',
                    icon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Pincode is required';
                      if (v.length != 6) return 'Enter valid 6-digit pincode';
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Default toggle ───────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: SwitchListTile(
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v),
                  activeThumbColor: AppTheme.primaryGreen,
                  title: const Text(
                    'Set as Default Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Use this address automatically at checkout',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Save button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isMutating ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  child: isMutating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEdit ? 'Update Address' : 'Save Address'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textGrey,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 50, color: Color(0xFFF3F4F6));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppTheme.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
        prefixIcon: Icon(icon, size: 20, color: AppTheme.textGrey),
        border: InputBorder.none,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
