import 'package:flutter/material.dart';
import 'package:jaibee1/models/goal_model.dart';
import 'package:intl/intl.dart';

class AddGoalDialog extends StatefulWidget {
  final Function(Goal) onAdd;

  const AddGoalDialog({required this.onAdd, Key? key}) : super(key: key);

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _savedAmountController = TextEditingController();
  DateTime? _targetDate;
  List<int> _milestones = [25, 50, 75];

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

  void _addMilestone() {
    setState(() {
      _milestones.add(100);
    });
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestones.removeAt(index);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _targetDate != null) {
      final goal = Goal(
        name: _nameController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text.trim()),
        savedAmount: double.parse(_savedAmountController.text.trim()),
        targetDate: _targetDate!,
        milestones: _milestones,
      );
      widget.onAdd(goal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Goal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Goal Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Target Amount'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _savedAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Saved Amount'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid amount';
                  }
                  final target = double.tryParse(_targetAmountController.text.trim()) ?? 0;
                  if (parsed > target) {
                    return 'Saved amount cannot exceed target amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Target Date:'),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(
                      _targetDate != null
                          ? DateFormat.yMMMd().format(_targetDate!)
                          : 'Pick Date',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _milestones
                    .asMap()
                    .entries
                    .map(
                      (entry) => Chip(
                        label: Text('${entry.value}%'),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => _removeMilestone(entry.key),
                      ),
                    )
                    .toList(),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addMilestone,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Milestone'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add Goal'),
        ),
      ],
    );
  }
}
