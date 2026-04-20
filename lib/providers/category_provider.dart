import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';

final categoriesProvider = StreamProvider<List<Category>>((ref) async* {
  final box = Hive.box<Category>('categories');

  // If no categories exist, add default ones
  if (box.isEmpty) {
    for (var category in defaultCategories) {
      await box.put(category.id, category);
    }
  }

  // Emit initial values
  yield box.values.toList();

  // Listen to changes in the box
  await for (final _ in box.watch()) {
    yield box.values.toList();
  }
});

final addCategoryProvider = Provider<Function>((ref) {
  return (Category category) async {
    final box = Hive.box<Category>('categories');
    await box.put(category.id, category);
  };
});

final updateCategoryProvider = Provider<Function>((ref) {
  return (Category category) async {
    final box = Hive.box<Category>('categories');
    await box.put(category.id, category);
  };
});

final deleteCategoryProvider = Provider<Function>((ref) {
  return (String categoryId) async {
    final box = Hive.box<Category>('categories');
    await box.delete(categoryId);
  };
});
