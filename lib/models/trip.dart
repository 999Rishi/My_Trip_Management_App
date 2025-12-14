import 'package:hive/hive.dart';

part 'trip.g.dart';

@HiveType(typeId: 1)
class Trip extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? imageUrl;

  @HiveField(3)
  late DateTime startDate;

  @HiveField(4)
  late DateTime endDate;

  @HiveField(5)
  late List<String> memberIds; // List of user IDs

  @HiveField(6)
  late String ownerId; // User ID of the trip owner

  @HiveField(7)
  late List<String> adminIds; // List of user IDs who are admins

  @HiveField(8)
  late String baseCurrency; // Base currency for the trip

  @HiveField(9)
  late bool isArchived; // Whether the trip is archived

  Trip({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.memberIds,
    required this.ownerId,
    required this.adminIds,
    this.baseCurrency = 'USD',
    this.isArchived = false,
  });

  Trip.empty() {
    id = '';
    name = '';
    startDate = DateTime.now();
    endDate = DateTime.now();
    memberIds = [];
    ownerId = '';
    adminIds = [];
    baseCurrency = 'USD';
    isArchived = false;
  }
}
