import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jaibee1/data/models/goal_model.dart';
import 'package:jaibee1/shared/widgets/custom_app_bar.dart';
import 'package:jaibee1/l10n/s.dart';

class AddGoalScreen extends StatefulWidget {
  final Function(Goal) onAdd;

  const AddGoalScreen({required this.onAdd, Key? key}) : super(key: key);

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
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
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
        milestones: [], // empty list since milestones removed
      );
      widget.onAdd(goal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: localizer.addNewGoal,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: localizer.goalName),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? localizer.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: localizer.targetAmount),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _savedAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: localizer.savedAmount),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizer.required;
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed < 0) {
                    return localizer.enterValidAmount;
                  }
                  final target = double.tryParse(_targetAmountController.text.trim()) ?? 0;
                  if (parsed > target) {
                    return localizer.savedMoreThanTarget;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('${localizer.targetDate}:'),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(
                      _targetDate != null
                          ? DateFormat.yMMMd().format(_targetDate!)
                          : localizer.pickDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(localizer.addGoal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
