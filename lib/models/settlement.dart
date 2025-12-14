import 'package:hive/hive.dart';

part 'settlement.g.dart';

@HiveType(typeId: 4)
class Settlement extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String tripId;

  @HiveField(2)
  late String fromUserId; // User who owes money

  @HiveField(3)
  late String toUserId; // User who is owed money

  @HiveField(4)
  late double amount;

  @HiveField(5)
  late String currency;

  @HiveField(6)
  late DateTime dateTime;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  late String paymentMethod; // cash, upi, bank_transfer, etc.

  @HiveField(9)
  late bool isSettled;

  Settlement({
    required this.id,
    required this.tripId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.currency,
    required this.dateTime,
    this.notes,
    this.paymentMethod = 'cash',
    this.isSettled = false,
  });

  Settlement.empty() {
    id = '';
    tripId = '';
    fromUserId = '';
    toUserId = '';
    amount = 0.0;
    currency = 'USD';
    dateTime = DateTime.now();
    paymentMethod = 'cash';
    isSettled = false;
  }
}
