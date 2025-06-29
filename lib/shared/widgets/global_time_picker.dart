import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<TimeOfDay?> showGlobalCupertinoTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  TimeOfDay tempSelectedTime = initialTime;
  TimeOfDay? pickedTime;

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
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    0,
                    0,
                    0,
                    initialTime.hour,
                    initialTime.minute,
                  ),
                  use24hFormat: false, // هنا فعل AM/PM
                  onDateTimeChanged: (newDateTime) {
                    tempSelectedTime = TimeOfDay(
                      hour: newDateTime.hour,
                      minute: newDateTime.minute,
                    );
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  pickedTime = tempSelectedTime;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );

  return pickedTime;
}
