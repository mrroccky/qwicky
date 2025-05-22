import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerWidget<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemNameGetter;
  final void Function(List<DateTime?>) onConfirm;

  const DateTimePickerWidget({
    super.key,
    required this.items,
    required this.itemNameGetter,
    required this.onConfirm,
  });

  @override
  State<DateTimePickerWidget<T>> createState() => _DateTimePickerWidgetState<T>();
}

class _DateTimePickerWidgetState<T> extends State<DateTimePickerWidget<T>> {
  late List<DateTime?> selectedDateTimes;

  @override
  void initState() {
    super.initState();
    selectedDateTimes = List<DateTime?>.filled(widget.items.length, null);
  }

  Future<void> _pickDateTime(int index) async {
    final now = DateTime.now();
    final initialDate = selectedDateTimes[index] ?? now;

    // Pick date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      // Pick time
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (selectedTime != null) {
        setState(() {
          selectedDateTimes[index] = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Date and Time'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return ListTile(
              title: Text(widget.itemNameGetter(item)),
              subtitle: Text(
                selectedDateTimes[index] != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTimes[index]!)
                    : 'Not selected',
              ),
              onTap: () => _pickDateTime(index),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(selectedDateTimes);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}