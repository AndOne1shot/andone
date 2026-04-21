import 'package:flutter/material.dart';

class ScheduleSelector extends StatefulWidget {
  final DateTime initialStartTime;
  final DateTime initialEndTime;
  final Function(DateTime start, DateTime end) onChanged;
  final bool isRepeat;
  final List<int> repeatDays;

  const ScheduleSelector({
    super.key,
    required this.initialStartTime,
    required this.initialEndTime,
    required this.onChanged,
    this.isRepeat = false,
    this.repeatDays = const [],
  });

  @override
  State<ScheduleSelector> createState() => _ScheduleSelectorState();
}

class _ScheduleSelectorState extends State<ScheduleSelector> {
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.initialStartTime;
    _startTime = TimeOfDay.fromDateTime(widget.initialStartTime);
    _endTime = TimeOfDay.fromDateTime(widget.initialEndTime);
  }

  Future<void> _pickDate() async {
    final isWeekly = widget.isRepeat && widget.repeatDays.isNotEmpty;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
      selectableDayPredicate: isWeekly
          ? (day) => widget.repeatDays.contains(day.weekday)
          : null,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _notifyParent();
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
      _notifyParent();
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
      _notifyParent();
    }
  }

  void _notifyParent() {
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    widget.onChanged(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isRepeat ? '시작일 설정' : '일정 설정',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 175,
            child: OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(
                widget.isRepeat
                    ? "시작일: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}"
                    : "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}",
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickStartTime,
                icon: const Icon(Icons.access_time, size: 18),
                label: Text(_startTime.format(context)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text("~"),
            ),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickEndTime,
                icon: const Icon(Icons.access_time, size: 18),
                label: Text(_endTime.format(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
