import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Track rendering performance
  static final int _frameCount = 0;
  static final int _lastFrameTime = 0;
  static final double _fps = 0.0;

  // Memory usage tracking
  static int _memoryUsage = 0;

  // Initialize performance monitoring
  void initialize() {
    // Start FPS monitoring
    _startFPSMonitoring();

    // Start memory monitoring
    _startMemoryMonitoring();
  }

  // Start FPS monitoring
  void _startFPSMonitoring() {
    // In a real app, we would use Flutter's performance overlay or a custom solution
    // For now, we'll just log a message
    if (kDebugMode) {
      print('Performance monitoring started');
    }
  }

  // Start memory monitoring
  void _startMemoryMonitoring() {
    // Periodically check memory usage
    Timer.periodic(Duration(seconds: 5), (timer) {
      _updateMemoryUsage();
    });
  }

  // Update memory usage
  void _updateMemoryUsage() {
    // In a real app, we would use Flutter's memory info
    // For now, we'll just simulate memory usage
    final random = Random();
    _memoryUsage = 50 + random.nextInt(50); // Random value between 50-100 MB

    if (kDebugMode) {
      print('Memory usage: $_memoryUsage MB');
    }
  }

  // Get current FPS
  static double getFPS() {
    return _fps;
  }

  // Get current memory usage
  static int getMemoryUsage() {
    return _memoryUsage;
  }

  // Optimize list rendering
  static bool shouldUseListViewOptimization(int itemCount) {
    // Use ListView optimization for lists with more than 20 items
    return itemCount > 20;
  }

  // Optimize image loading
  static bool shouldUseImageCaching(String imageUrl) {
    // Cache images that are likely to be reused
    return imageUrl.isNotEmpty;
  }

  // Optimize database queries
  static bool shouldUseQueryPagination(int totalCount) {
    // Use pagination for queries with more than 100 items
    return totalCount > 100;
  }

  // Debounce function calls
  static Function debounce(Function func, Duration delay) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, () => func());
    };
  }

  // Throttle function calls
  static Function throttle(Function func, Duration delay) {
    bool throttled = false;
    return () {
      if (!throttled) {
        func();
        throttled = true;
        Future.delayed(delay).then((_) => throttled = false);
      }
    };
  }

  // Log performance metrics
  static void logPerformance(String operation, Duration duration) {
    if (kDebugMode) {
      print('PERFORMANCE: $operation took ${duration.inMilliseconds}ms');
    }

    // In a real app, we might send this to analytics
  }

  // Profile a function
  static Future<T> profileAsync<T>(
    Future<T> Function() func,
    String name,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await func();
      stopwatch.stop();
      logPerformance(name, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      logPerformance('$name (failed)', stopwatch.elapsed);
      rethrow;
    }
  }

  // Profile a synchronous function
  static T profileSync<T>(T Function() func, String name) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = func();
      stopwatch.stop();
      logPerformance(name, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      logPerformance('$name (failed)', stopwatch.elapsed);
      rethrow;
    }
  }
}
