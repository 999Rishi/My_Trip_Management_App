import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StateProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider);
  return user != null;
});

final signInProvider = Provider<Function>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.signInWithEmailAndPassword;
});

final signUpProvider = Provider<Function>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.signUpWithEmailAndPassword;
});

final signOutProvider = Provider<Function>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.signOut;
});

final updatePreferencesProvider = Provider<Function>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.updatePreferences;
});
