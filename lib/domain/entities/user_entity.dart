class UserEntity {
  final String id;
  final String name;
  final String email;
  final String mobileNo;
  final String avatarUrl;
  final String address;
  final double walletBalance;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNo,
    this.avatarUrl = '',
    this.address = '',
    this.walletBalance = 0.0,
  });


  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
