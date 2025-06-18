import 'package:flutter/material.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jaibee1/models/goal_model.dart';
import 'package:jaibee1/screens/add_goal_screen.dart';
import 'package:jaibee1/screens/edit_goal_dialog.dart';
import 'package:jaibee1/widgets/app_background.dart';
import 'package:jaibee1/widgets/custom_app_bar.dart';
import 'package:jaibee1/providers/mint_jade_theme.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late Box<Goal> _goalBox;

  @override
  void initState() {
    super.initState();
    _goalBox = Hive.box<Goal>('goals');
  }

  void _addGoal(Goal goal) {
    _goalBox.add(goal);
  }

  void _updateGoal(Goal goal, int index) {
    _goalBox.putAt(index, goal);
  }

  void _deleteGoal(int index) {
    _goalBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;
    final localizer = S.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: localizer.financialGoals,
        showBackButton: true,
      ),
      body: AppBackground(
        child: ValueListenableBuilder(
          valueListenable: _goalBox.listenable(),
          builder: (context, Box<Goal> box, _) {
            if (box.values.isEmpty) {
              return Center(
                child: Text(
                  localizer.noGoals,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final goal = box.getAt(index);
                if (goal == null) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (Theme.of(context).brightness == Brightness.light)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                    border: Border.all(
                      color: mintTheme.buttonColor.withOpacity(
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.3
                            : 0.4,
                      ),
                      width: 1.2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: mintTheme.buttonColor.withOpacity(0.15),
                      child: Icon(
                        Icons.flag,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    title: Text(
                      goal.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${localizer.savings}: ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.black87,
                                ),
                              ),
                              Image.asset(
                                'assets/images/Saudi_Riyal_Symbol.png',
                                width: 12,
                                height: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${goal.savedAmount.toStringAsFixed(2)} / ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.black87,
                                ),
                              ),
                              Image.asset(
                                'assets/images/Saudi_Riyal_Symbol.png',
                                width: 12,
                                height: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                goal.targetAmount.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),
                          Text(
                            '${localizer.expectedDate}: ${goal.targetDate.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[500]
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditGoalDialog(
                          goal: goal,
                          index: index,
                          onUpdate: _updateGoal,
                          onDelete: _deleteGoal,
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddGoalScreen(onAdd: _addGoal)),
          );
        },
        backgroundColor: mintTheme.buttonColor,
        label: Text(localizer.addGoal),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
