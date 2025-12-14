import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import '../models/trip.dart';

// Use StreamProvider to automatically refresh when trips change
final tripsProvider = StreamProvider<List<Trip>>((ref) {
  final box = Hive.box<Trip>('trips');

  // Create a stream controller
  final controller = StreamController<List<Trip>>();

  // Emit initial values
  controller.sink.add(box.values.toList());

  // Listen to changes in the box
  final subscription = box.watch().listen((event) {
    controller.sink.add(box.values.toList());
  });

  // Close subscription when provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

final addTripProvider = Provider<Future<void> Function(Trip)>((ref) {
  return (Trip trip) async {
    final box = Hive.box<Trip>('trips');
    await box.put(trip.id, trip);
  };
});

final updateTripProvider = Provider<Future<void> Function(Trip)>((ref) {
  return (Trip trip) async {
    final box = Hive.box<Trip>('trips');
    await box.put(trip.id, trip);
  };
});

final deleteTripProvider = Provider<Future<void> Function(String)>((ref) {
  return (String tripId) async {
    final box = Hive.box<Trip>('trips');
    await box.delete(tripId);
  };
});
