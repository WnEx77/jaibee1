// Importing Hive package for local storage
import 'package:hive/hive.dart';

// Part statement is used for code
// generation for the Transaction class.
part 'trancs.g.dart';

// Defining a Hive Type with a unique
// typeId of 0 to store Transaction objects.
@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final bool isIncome;

  @HiveField(3)
  final DateTime date;

  @HiveField(4) // 👈 New field
  final String? description;

  Transaction({
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.description, // 👈 Include in constructor
  });
}
