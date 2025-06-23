import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showGlobalCupertinoDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? minDate,
  DateTime? maxDate,
}) async {
  DateTime tempSelectedDate = initialDate;
  DateTime? pickedDate;

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? Colors.grey[900] : Colors.white;

  await showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 250,
                child: CupertinoDatePicker(
                  initialDateTime: tempSelectedDate,
                  minimumDate: minDate ?? DateTime(2000),
                  maximumDate: maxDate ?? DateTime.now(),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (newDate) => tempSelectedDate = newDate,
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  pickedDate = tempSelectedDate;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return pickedDate;
}