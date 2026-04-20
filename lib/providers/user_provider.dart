import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';

final usersProvider = StreamProvider<List<User>>((ref) async* {
  final box = Hive.box<User>('users');

  // Emit initial values
  yield box.values.toList();

  // Listen to changes in the box
  await for (final _ in box.watch()) {
    yield box.values.toList();
  }
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
