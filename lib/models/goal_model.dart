import 'package:hive/hive.dart';

part 'goal_model.g.dart'; // Needed for build_runner

@HiveType(typeId: 4)
class Goal extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double savedAmount;

  @HiveField(3)
  DateTime targetDate;

  @HiveField(4)
  List<int> milestones;

  Goal({
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.milestones,
  });
}
