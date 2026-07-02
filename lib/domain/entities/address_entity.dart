class AddressEntity {
  final String id;
  final String label;
  final String name;
  final String mobile;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.name,
    required this.mobile,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  factory AddressEntity.fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['_id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Home',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      addressLine: json['address_line']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'name': name,
      'mobile': mobile,
      'address_line': addressLine,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_default': isDefault,
    };
  }

  AddressEntity copyWith({
    String? id,
    String? label,
    String? name,
    String? mobile,
    String? addressLine,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
