import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/data/fake_data.dart';
import 'package:veggie_mart/domain/entities/user_entity.dart';

final userProvider = Provider<UserEntity>((ref) {
  return FakeData.currentUser;
});
