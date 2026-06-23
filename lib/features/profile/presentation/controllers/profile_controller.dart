import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_project/core/data/fake_data.dart';
import 'package:riverpod_project/features/auth/domain/entities/user_entity.dart';

final userProvider = Provider<UserEntity>((ref) {
  return FakeData.currentUser;
});
