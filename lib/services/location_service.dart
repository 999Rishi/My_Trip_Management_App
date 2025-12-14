import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart'
    if (dart.library.js) 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    // Skip on web
    if (kIsWeb) {
      return false;
    }

    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service status: $e');
      return false;
    }
  }

  // Request location permissions
  Future<LocationPermission> requestPermission() async {
    // Skip on web
    if (kIsWeb) {
      return LocationPermission.denied;
    }

    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      print('Error requesting location permission: $e');
      return LocationPermission.denied;
    }
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    // Skip on web
    if (kIsWeb) {
      throw Exception('Location services not available on web');
    }

    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting current location: $e');
      rethrow;
    }
  }

  // Get place name from coordinates
  Future<String> getPlaceName(double latitude, double longitude) async {
    // Skip on web
    if (kIsWeb) {
      return 'Web Location';
    }

    try {
      // In a real app, this would use a geocoding service
      // For now, we'll just return a mock place name
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Simulate network delay

      // Simple mock implementation
      if (latitude > 0 && longitude > 0) {
        return 'Place at ($latitude, $longitude)';
      }

      return 'Unknown Location';
    } catch (e) {
      print('Error getting place name: $e');
      return 'Unknown Location';
    }
  }

  // Get address from coordinates
  Future<String> getAddress(double latitude, double longitude) async {
    // Skip on web
    if (kIsWeb) {
      return 'Web Address';
    }

    try {
      // In a real app, this would use a geocoding service
      // For now, we'll just return a mock address
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Simulate network delay

      // Simple mock implementation
      return '123 Main Street, City, State 12345';
    } catch (e) {
      print('Error getting address: $e');
      return 'Unknown Address';
    }
  }
}
