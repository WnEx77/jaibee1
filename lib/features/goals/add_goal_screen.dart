import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jaibee/data/models/goal_model.dart';
import 'package:jaibee/shared/widgets/custom_app_bar.dart';
import 'package:jaibee/l10n/s.dart';
import 'package:flutter/cupertino.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:jaibee/shared/widgets/global_date_picker.dart';

class AddGoalScreen extends StatefulWidget {
  final Function(Goal) onAdd;

  const AddGoalScreen({required this.onAdd, super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _savedAmountController = TextEditingController();
  DateTime? _targetDate;

  void _pickDate() async {
    final now = DateTime.now();
    final initial = _targetDate ?? now;

    final picked = await showGlobalCupertinoDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      minDate: now,
      maxDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _targetDate != null) {
      final goal = Goal(
        name: _nameController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text.trim()),
        savedAmount: double.parse(_savedAmountController.text.trim()),
        targetDate: _targetDate!,
        milestones: [],
      );
      widget.onAdd(goal);
      Flushbar(
        message: S.of(context)!.goalAddedSuccessfully,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.BOTTOM,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ).show(context).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: localizer.addNewGoal, showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(Icons.flag, color: Colors.teal, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    localizer.addNewGoal,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.teal[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: localizer.goalName,
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? localizer.required
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: localizer.targetAmount,
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizer.required;
                      }
                      final parsed = double.tryParse(value.trim());
                      if (parsed == null || parsed <= 0) {
                        return localizer.enterValidAmount;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _savedAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: localizer.savedAmount,
                      prefixIcon: Icon(Icons.savings),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizer.required;
                      }
                      final parsed = double.tryParse(value.trim());
                      if (parsed == null || parsed < 0) {
                        return localizer.enterValidAmount;
                      }
                      final target =
                          double.tryParse(
                            _targetAmountController.text.trim(),
                          ) ??
                          0;
                      if (parsed > target) {
                        return localizer.savedMoreThanTarget;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: localizer.targetDate,
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: Icon(Icons.edit_calendar),
                        ),
                        controller: TextEditingController(
                          text: _targetDate != null
                              ? DateFormat.yMMMd().format(_targetDate!)
                              : '',
                        ),
                        validator: (_) =>
                            _targetDate == null ? localizer.required : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add_circle_outline),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          localizer.addGoal,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
