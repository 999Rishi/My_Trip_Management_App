import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 3)
class Category extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late int color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Category.empty() {
    id = '';
    name = '';
    icon = 'local_dining';
    color = 0xFF6200EE;
  }
}

// Predefined categories
final List<Category> defaultCategories = [
  Category(id: 'food', name: 'Food', icon: 'local_dining', color: 0xFF6200EE),
  Category(id: 'hotel', name: 'Hotel', icon: 'hotel', color: 0xFF03DAC6),
  Category(id: 'travel', name: 'Travel', icon: 'train', color: 0xFF018786),
  Category(
    id: 'tickets',
    name: 'Tickets',
    icon: 'confirmation_number',
    color: 0xFF3700B3,
  ),
  Category(id: 'misc', name: 'Miscellaneous', icon: 'help', color: 0xFFBB86FC),
];
