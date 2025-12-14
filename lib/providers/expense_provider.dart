import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import '../models/expense.dart';

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final box = Hive.box<Expense>('expenses');

  // Create a stream controller
  final controller = StreamController<List<Expense>>();

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

final tripExpensesProvider = StreamProvider.family<List<Expense>, String>((
  ref,
  tripId,
) {
  final box = Hive.box<Expense>('expenses');

  // Create a stream controller
  final controller = StreamController<List<Expense>>();

  // Emit initial values
  controller.sink.add(
    box.values.where((expense) => expense.tripId == tripId).toList(),
  );

  // Listen to changes in the box
  final subscription = box.watch().listen((event) {
    controller.sink.add(
      box.values.where((expense) => expense.tripId == tripId).toList(),
    );
  });

  // Close subscription when provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

final addExpenseProvider = Provider<Function>((ref) {
  return (Expense expense) async {
    final box = Hive.box<Expense>('expenses');
    await box.put(expense.id, expense);
  };
});

final updateExpenseProvider = Provider<Function>((ref) {
  return (Expense expense) async {
    final box = Hive.box<Expense>('expenses');
    await box.put(expense.id, expense);
  };
});

final deleteExpenseProvider = Provider<Function>((ref) {
  return (String expenseId) async {
    final box = Hive.box<Expense>('expenses');
    await box.delete(expenseId);
  };
});
