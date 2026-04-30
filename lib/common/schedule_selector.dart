// Todo 날짜 및 시간 범위를 선택하는 위젯.
// 날짜 선택은 DatePicker, 시간 선택은 드럼롤 방식(showDrumRollTimePicker)을 사용.
// 반복 설정 시 isRepeat=true, repeatDays를 전달하면 날짜 피커에서 해당 요일만 선택 가능.
//
// 사용법:
//   ScheduleSelector(
//     initialStartTime: _startTime,    // DateTime
//     initialEndTime: _endTime,        // DateTime
//     onChanged: (start, end) => setState(() { _startTime = start; _endTime = end; }),
//     isRepeat: true,                  // 반복 todo 여부 (선택)
//     repeatDays: _repeatDays,         // 반복 요일 List<int> (선택)
//   )
import 'package:andone/common/drum_roll_time_picker.dart';
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
      selectableDayPredicate:
          isWeekly ? (day) => widget.repeatDays.contains(day.weekday) : null,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.blue,
            surface: Color(0xFF2D2D2D),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _notifyParent();
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showDrumRollTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() => isStart ? _startTime = picked : _endTime = picked);
      _notifyParent();
    }
  }

  void _notifyParent() {
    final start = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _startTime.hour, _startTime.minute,
    );
    final end = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _endTime.hour, _endTime.minute,
    );
    widget.onChanged(start, end);
  }

  String _fmtDate() =>
      '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일';

  String _fmtTime(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final period = h < 12 ? '오전' : '오후';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$period $h12:$m';
  }

  Widget _buildDateButton() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                border: Border.all(color: Colors.blue.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.calendar_today_outlined, color: Colors.blue, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.isRepeat ? '시작일' : '날짜',
                    style: const TextStyle(fontSize: 10, color: Colors.white38)),
                  Text(_fmtDate(),
                    style: const TextStyle(
                      fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(String label, TimeOfDay time, bool isStart) {
    return GestureDetector(
      onTap: () => _pickTime(isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.blue, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
                Text(_fmtTime(time),
                  style: const TextStyle(
                    fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateButton(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTimeButton('시작 시간', _startTime, true)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('→', style: TextStyle(color: Colors.white38, fontSize: 16)),
            ),
            Expanded(child: _buildTimeButton('종료 시간', _endTime, false)),
          ],
        ),
      ],
    );
  }
}
