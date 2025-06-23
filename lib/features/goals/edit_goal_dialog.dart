import 'package:flutter/material.dart';
import 'package:jaibee1/data/models/goal_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:jaibee1/shared/widgets/global_date_picker.dart';
import 'package:jaibee1/shared/widgets/global_confirm_delete_dialog.dart';

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
    super.key,
  });

  @override
  State<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _savedAmountController;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _targetAmountController = TextEditingController(
      text: widget.goal.targetAmount.toString(),
    );
    _savedAmountController = TextEditingController(
      text: widget.goal.savedAmount.toString(),
    );
    _targetDate = widget.goal.targetDate;
  }

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
      final updatedGoal = Goal(
        name: _nameController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text.trim()),
        savedAmount: double.parse(_savedAmountController.text.trim()),
        targetDate: _targetDate!,
        milestones: [],
      );
      widget.onUpdate(updatedGoal, widget.index);
      Navigator.pop(context);
    }
  }

  void _confirmDelete() async {
    final localizer = S.of(context)!;
    final confirmed = await showGlobalConfirmDeleteDialog(
      context: context,
      title: localizer.deleteGoal,
      message: localizer.deleteGoalConfirmation,
    );
    if (confirmed == true) {
      widget.onDelete(widget.index);
      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).pop(); // Return to previous
      // Show success message
      Flushbar(
        message: localizer.goalDeleted,
        icon: const Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 28,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.BOTTOM,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizer = S.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag, color: Colors.teal, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizer!.editGoal,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.teal[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: localizer.goalName,
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? localizer.requiredField
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: localizer.targetAmount,
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizer.requiredField;
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
                      prefixIcon: const Icon(Icons.savings),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizer.requiredField;
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
                        return localizer.savedAmountExceedsTarget;
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
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: const Icon(Icons.edit_calendar),
                        ),
                        controller: TextEditingController(
                          text: _targetDate != null
                              ? DateFormat.yMMMd(
                                  localizer.localeName,
                                ).format(_targetDate!)
                              : '',
                        ),
                        validator: (_) =>
                            _targetDate == null ? localizer.pickDate : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              localizer.delete,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _confirmDelete,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              localizer.save,
                              style: const TextStyle(fontSize: 16),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
