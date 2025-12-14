import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import '../models/settlement.dart';

final allSettlementsProvider = StreamProvider<List<Settlement>>((ref) {
  final box = Hive.box<Settlement>('settlements');

  // Create a stream controller
  final controller = StreamController<List<Settlement>>();

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

final tripSettlementsStreamProvider =
    StreamProvider.family<List<Settlement>, String>((ref, tripId) {
      final box = Hive.box<Settlement>('settlements');

      // Create a stream controller
      final controller = StreamController<List<Settlement>>();

      // Emit initial values
      controller.sink.add(
        box.values.where((settlement) => settlement.tripId == tripId).toList(),
      );

      // Listen to changes in the box
      final subscription = box.watch().listen((event) {
        controller.sink.add(
          box.values
              .where((settlement) => settlement.tripId == tripId)
              .toList(),
        );
      });

      // Close subscription when provider is disposed
      ref.onDispose(() {
        subscription.cancel();
        controller.close();
      });

      return controller.stream;
    });

final addSettlementProvider = Provider<Function>((ref) {
  return (Settlement settlement) async {
    final box = Hive.box<Settlement>('settlements');
    await box.put(settlement.id, settlement);
  };
});

final updateSettlementProvider = Provider<Function>((ref) {
  return (Settlement settlement) async {
    final box = Hive.box<Settlement>('settlements');
    await box.put(settlement.id, settlement);
  };
});

final deleteSettlementProvider = Provider<Function>((ref) {
  return (String settlementId) async {
    final box = Hive.box<Settlement>('settlements');
    await box.delete(settlementId);
  };
});
