import 'dart:async';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  final List<Function> _authCallbacks = [];

  // Initialize the service
  Future<void> initialize() async {
    // In a real app, this would check for existing session
    // For now, we'll just initialize without a user
    _currentUser = null;
  }

  // Get current user
  User? getCurrentUser() => _currentUser;

  // Check if user is authenticated
  bool isAuthenticated() => _currentUser != null;

  // Sign in with email and password
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    // In a real app, this would call an authentication API
    // For now, we'll just create a mock user
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay

    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first,
      email: email,
      preferredCurrency: 'USD',
      isDarkModeEnabled: false,
    );

    _notifyAuthStateChange();
    return _currentUser!;
  }

  // Sign in with Google
  Future<User> signInWithGoogle() async {
    // In a real app, this would handle Google authentication
    // For now, we'll just create a mock user
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay

    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Google User',
      email: 'google.user@example.com',
      preferredCurrency: 'USD',
      isDarkModeEnabled: false,
    );

    _notifyAuthStateChange();
    return _currentUser!;
  }

  // Sign in with phone
  Future<User> signInWithPhone(String phoneNumber) async {
    // In a real app, this would handle phone authentication
    // For now, we'll just create a mock user
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay

    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Phone User',
      phoneNumber: phoneNumber,
      preferredCurrency: 'USD',
      isDarkModeEnabled: false,
    );

    _notifyAuthStateChange();
    return _currentUser!;
  }

  // Sign up with email and password
  Future<User> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    // In a real app, this would call an authentication API
    // For now, we'll just create a mock user
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay

    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      preferredCurrency: 'USD',
      isDarkModeEnabled: false,
    );

    _notifyAuthStateChange();
    return _currentUser!;
  }

  // Sign out
  Future<void> signOut() async {
    // In a real app, this would call the sign out API
    // For now, we'll just clear the current user
    await Future.delayed(Duration(milliseconds: 200)); // Simulate network delay

    _currentUser = null;
    _notifyAuthStateChange();
  }

  // Add auth state change callback
  void addAuthStateCallback(Function callback) {
    _authCallbacks.add(callback);
  }

  // Remove auth state change callback
  void removeAuthStateCallback(Function callback) {
    _authCallbacks.remove(callback);
  }

  // Notify all callbacks of auth state change
  void _notifyAuthStateChange() {
    for (final callback in _authCallbacks) {
      callback(_currentUser);
    }
  }

  // Update user profile
  Future<void> updateProfile(User updatedUser) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }

    // In a real app, this would call an API to update the user
    // For now, we'll just update locally
    await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay

    _currentUser = updatedUser;
    _notifyAuthStateChange();
  }

  // Update user preferences
  Future<void> updatePreferences({
    String? preferredCurrency,
    bool? isDarkModeEnabled,
  }) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }

    // In a real app, this would call an API to update preferences
    // For now, we'll just update locally
    await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay

    if (preferredCurrency != null) {
      _currentUser!.preferredCurrency = preferredCurrency;
    }

    if (isDarkModeEnabled != null) {
      _currentUser!.isDarkModeEnabled = isDarkModeEnabled;
    }

    _notifyAuthStateChange();
  }
}
