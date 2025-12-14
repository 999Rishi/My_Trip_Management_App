import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 2)
class Expense extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String tripId;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late String currency;

  @HiveField(5)
  late String paidById; // User ID of who paid

  @HiveField(6)
  late List<String> participantIds; // List of user IDs who participated

  @HiveField(7)
  late Map<String, double> shares; // Map of user ID to their share amount

  @HiveField(8)
  late String categoryId;

  @HiveField(9)
  late DateTime dateTime;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  String? receiptImageUrl;

  @HiveField(12)
  late String splitType; // equal, unequal, percentage, shares, itemized

  @HiveField(13)
  late bool isSettled; // Whether the expense has been settled

  Expense({
    required this.id,
    required this.tripId,
    required this.description,
    required this.amount,
    required this.currency,
    required this.paidById,
    required this.participantIds,
    required this.shares,
    required this.categoryId,
    required this.dateTime,
    this.notes,
    this.receiptImageUrl,
    this.splitType = 'equal',
    this.isSettled = false,
  });

  Expense.empty() {
    id = '';
    tripId = '';
    description = '';
    amount = 0.0;
    currency = 'USD';
    paidById = '';
    participantIds = [];
    shares = {};
    categoryId = '';
    dateTime = DateTime.now();
    splitType = 'equal';
    isSettled = false;
  }
}
