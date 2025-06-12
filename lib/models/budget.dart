import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 2)  // Use a unique typeId (different from Category)
class Budget extends HiveObject {
  @HiveField(0)
   String category;

  @HiveField(1)
   double limit;

  Budget({required this.category, required this.limit});
}
