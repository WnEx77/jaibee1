import 'package:flutter/material.dart';
import 'package:jaibee1/models/goal_model.dart';
import 'package:intl/intl.dart';

class EditGoalDialog extends StatefulWidget {
  final Goal goal;
  final int index;
  final Function(Goal updatedGoal, int index) onUpdate;
  final Function(int index) onDelete;

  const EditGoalDialog({
    required this.goal,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  State<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _savedAmountController;
  DateTime? _targetDate;
  List<int> _milestones = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _targetAmountController =
        TextEditingController(text: widget.goal.targetAmount.toString());
    _savedAmountController =
        TextEditingController(text: widget.goal.savedAmount.toString());
    _targetDate = widget.goal.targetDate;
    _milestones = List.from(widget.goal.milestones);
  }

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
      final updatedGoal = Goal(
        name: _nameController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text.trim()),
        savedAmount: double.parse(_savedAmountController.text.trim()),
        targetDate: _targetDate!,
        milestones: _milestones,
      );
      widget.onUpdate(updatedGoal, widget.index);
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(widget.index);
              Navigator.pop(context); // Close confirm dialog
              Navigator.pop(context); // Close edit dialog
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Goal'),
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
          onPressed: _confirmDelete,
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
