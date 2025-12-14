import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final List<Function> _syncCallbacks = [];
  bool _isOnline = true;
  bool _isSyncing = false;

  // Initialize the service
  Future<void> initialize() async {
    // On web, assume online by default
    if (kIsWeb) {
      _isOnline = true;
      return;
    }

    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      final wasOnline = _isOnline;
      _isOnline = result.first != ConnectivityResult.none;

      // If we just came online, trigger sync
      if (!wasOnline && _isOnline) {
        _triggerSync();
      }
    });
  }

  // Check if device is online
  bool isOnline() => _isOnline;

  // Check if currently syncing
  bool isSyncing() => _isSyncing;

  // Add a callback to be notified when sync is needed
  void addSyncCallback(Function callback) {
    _syncCallbacks.add(callback);
  }

  // Remove a sync callback
  void removeSyncCallback(Function callback) {
    _syncCallbacks.remove(callback);
  }

  // Trigger synchronization
  Future<void> _triggerSync() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      // Notify all callbacks that sync is starting
      for (final callback in _syncCallbacks) {
        try {
          await callback();
        } catch (e) {
          print('Error in sync callback: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  // Manually trigger sync (e.g., when user pulls to refresh)
  Future<void> manualSync() async {
    if (!_isOnline) {
      throw Exception('Cannot sync while offline');
    }

    await _triggerSync();
  }

  // Queue an operation for when online
  void queueOperation(Function operation) {
    // In a real app, this would store the operation in a queue
    // For now, we'll just execute it immediately if online
    if (_isOnline) {
      operation();
    }
  }
}
