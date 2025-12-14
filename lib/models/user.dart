import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? phoneNumber;

  @HiveField(4)
  String? profileImageUrl;

  @HiveField(5)
  late String preferredCurrency;

  @HiveField(6)
  late bool isDarkModeEnabled;

  User({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    String? preferredCurrency,
    bool? isDarkModeEnabled,
  }) {
    this.preferredCurrency = preferredCurrency ?? 'USD';
    this.isDarkModeEnabled = isDarkModeEnabled ?? false;
  }

  User.empty() {
    id = '';
    name = '';
    preferredCurrency = 'USD';
    isDarkModeEnabled = false;
  }
}
