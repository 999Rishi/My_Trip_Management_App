import 'package:flutter/services.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  // Light haptic feedback (for subtle interactions)
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback not available on this device
      print('Haptic feedback not available: $e');
    }
  }

  // Medium haptic feedback (for normal interactions)
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback not available on this device
      print('Haptic feedback not available: $e');
    }
  }

  // Heavy haptic feedback (for significant interactions)
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptic feedback not available on this device
      print('Haptic feedback not available: $e');
    }
  }

  // Selection haptic feedback (for changing selections)
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback not available on this device
      print('Haptic feedback not available: $e');
    }
  }

  // Vibrate (generic vibration)
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      // Haptic feedback not available on this device
      print('Haptic feedback not available: $e');
    }
  }

  // Success notification
  static Future<void> successNotification() async {
    try {
      // Use selectionClick as a substitute for notificationSuccess
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback not available on this device
      print('Haptic feedback not available: $e');
    }
  }

  // Warning notification
  static Future<void> warningNotification() async {
    try {
      // Use mediumImpact as a substitute for notificationWarning
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback not available on this device
      print('Haptic feedback not available: $e');
    }
  }

  // Error notification
  static Future<void> errorNotification() async {
    try {
      // Use heavyImpact as a substitute for notificationError
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptic feedback not available on this device
      print('Haptic feedback not available: $e');
    }
  }
}
