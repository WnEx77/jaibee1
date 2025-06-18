import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jaibee1/models/goal_model.dart';
import 'package:jaibee1/screens/add_goal_screen.dart'; // You'll use full screen now
import 'package:jaibee1/screens/edit_goal_dialog.dart';
import 'package:jaibee1/widgets/app_background.dart';
import 'package:jaibee1/widgets/custom_app_bar.dart';

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
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Goals',
      ),
      body: AppBackground(
        child: ValueListenableBuilder(
          valueListenable: _goalBox.listenable(),
          builder: (context, Box<Goal> box, _) {
            if (box.values.isEmpty) {
              return const Center(
                child: Text(
                  'No goals added yet',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final goal = box.getAt(index);
                if (goal == null) return const SizedBox.shrink();

                return Card(
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(goal.name),
                    subtitle: Text(
                      'Saved: \$${goal.savedAmount.toStringAsFixed(2)} / '
                      'Target: \$${goal.targetAmount.toStringAsFixed(2)}',
                    ),
                    trailing: Text(
                      'Due: ${goal.targetDate.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12),
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
          // ✅ Navigate to AddGoalScreen instead of dialog
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddGoalScreen(onAdd: _addGoal),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 130, 148, 179),
        label: const Text('Add New Goal'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
