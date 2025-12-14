import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';

final usersProvider = FutureProvider<List<User>>((ref) async {
  final box = Hive.box<User>('users');
  return box.values.toList();
});

final currentUserProvider = StateProvider<User?>((ref) {
  return null;
});

final addUserProvider = Provider<Function>((ref) {
  return (User user) async {
    final box = Hive.box<User>('users');
    await box.put(user.id, user);
  };
});

final updateUserProvider = Provider<Function>((ref) {
  return (User user) async {
    final box = Hive.box<User>('users');
    await box.put(user.id, user);
  };
});
