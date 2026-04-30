import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<TimeOfDay?> showDrumRollTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: const Color(0xFF2D2D2D),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _DrumRollTimePicker(initialTime: initialTime),
  );
}

class _DrumRollTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  const _DrumRollTimePicker({required this.initialTime});

  @override
  State<_DrumRollTimePicker> createState() => _DrumRollTimePickerState();
}

class _DrumRollTimePickerState extends State<_DrumRollTimePicker> {
  late int _hour; // 0-23 내부값
  late int _minute;
  late FixedExtentScrollController _amPmCtrl;
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;

  bool _editingHour = false;
  bool _editingMinute = false;
  final _hourTF = TextEditingController();
  final _minuteTF = TextEditingController();
  final _hourFocus = FocusNode();
  final _minuteFocus = FocusNode();

  bool get _isAM => _hour < 12;
  // 1-12 표시용
  int get _hour12 => _hour % 12 == 0 ? 12 : _hour % 12;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _amPmCtrl = FixedExtentScrollController(initialItem: _isAM ? 0 : 1);
    _hourCtrl = FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _amPmCtrl.dispose();
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _hourTF.dispose();
    _minuteTF.dispose();
    _hourFocus.dispose();
    _minuteFocus.dispose();
    super.dispose();
  }

  // 12시간제 + AM/PM → 24시간
  int _to24Hour(int h12, bool isAM) {
    if (isAM) return h12 == 12 ? 0 : h12;
    return h12 == 12 ? 12 : h12 + 12;
  }

  void _onAmPmChanged(int index) {
    final newIsAM = index == 0;
    if (newIsAM == _isAM) return;
    setState(() => _hour = newIsAM ? _hour - 12 : _hour + 12);
  }

  void _onHourWheelChanged(int index) {
    final h12 = index + 1; // index 0 = 1시, index 11 = 12시
    setState(() => _hour = _to24Hour(h12, _isAM));
  }

  void _startEditHour() {
    _hourTF.text = _hour12.toString();
    setState(() {
      _editingHour = true;
      _editingMinute = false;
    });
    Future.delayed(
      const Duration(milliseconds: 50),
      () => _hourFocus.requestFocus(),
    );
  }

  void _startEditMinute() {
    _minuteTF.text = _minute.toString().padLeft(2, '0');
    setState(() {
      _editingMinute = true;
      _editingHour = false;
    });
    Future.delayed(
      const Duration(milliseconds: 50),
      () => _minuteFocus.requestFocus(),
    );
  }

  void _onHourTyped(String val) {
    final h = int.tryParse(val);
    if (h != null && h >= 1 && h <= 12) {
      setState(() => _hour = _to24Hour(h, _isAM));
      _hourCtrl.jumpToItem(h - 1);
    }
  }

  void _confirmHour() {
    final h = int.tryParse(_hourTF.text);
    if (h != null && h >= 1 && h <= 12) {
      setState(() {
        _hour = _to24Hour(h, _isAM);
        _editingHour = false;
      });
      _hourCtrl.jumpToItem(h - 1);
    } else {
      setState(() => _editingHour = false);
    }
  }

  void _onMinuteTyped(String val) {
    final m = int.tryParse(val);
    if (m != null && m >= 0 && m <= 59) {
      setState(() => _minute = m);
      _minuteCtrl.jumpToItem(m);
    }
  }

  void _confirmMinute() {
    final m = int.tryParse(_minuteTF.text);
    if (m != null && m >= 0 && m <= 59) {
      setState(() {
        _minute = m;
        _editingMinute = false;
      });
      _minuteCtrl.jumpToItem(m);
    } else {
      setState(() => _editingMinute = false);
    }
  }

  Widget _buildWheel({
    required FixedExtentScrollController ctrl,
    required int count,
    required int selected,
    required ValueChanged<int> onChanged,
    required bool compact,
    required String Function(int) label,
    double width = 80,
  }) {
    final height = compact ? 120.0 : 200.0;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: ctrl,
            itemExtent: 48,
            perspective: 0.003,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: count,
              builder: (context, index) => GestureDetector(
                onTap: () => ctrl.animateToItem(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: Center(
                  child: Text(
                    label(index),
                    style: TextStyle(
                      color: index == selected ? Colors.white : Colors.white38,
                      fontSize: index == selected ? 24 : 18,
                      fontWeight: index == selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay({
    required String value,
    required bool editing,
    required TextEditingController textCtrl,
    required FocusNode focusNode,
    required VoidCallback onTap,
    required VoidCallback onConfirm,
    required ValueChanged<String> onChanged,
  }) {
    if (editing) {
      return SizedBox(
        width: 72,
        child: TextField(
          controller: textCtrl,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            counterText: '',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          onChanged: onChanged,
          onSubmitted: (_) => onConfirm(),
          onTapOutside: (_) => onConfirm(),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white24)),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, keyboardHeight + 42),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '시간 선택',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '숫자를 탭하면 직접 입력할 수 있어요',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 16),
          // 상단 현재값 표시 (탭하면 직접 입력)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildValueDisplay(
                value: _hour12.toString().padLeft(2, '0'),
                editing: _editingHour,
                textCtrl: _hourTF,
                focusNode: _hourFocus,
                onTap: _startEditHour,
                onConfirm: _confirmHour,
                onChanged: _onHourTyped,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildValueDisplay(
                value: _minute.toString().padLeft(2, '0'),
                editing: _editingMinute,
                textCtrl: _minuteTF,
                focusNode: _minuteFocus,
                onTap: _startEditMinute,
                onConfirm: _confirmMinute,
                onChanged: _onMinuteTyped,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 드럼롤 휠 3개: 오전/오후 | 시 | 분
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 오전/오후 휠
              _buildWheel(
                ctrl: _amPmCtrl,
                count: 2,
                selected: _isAM ? 0 : 1,
                onChanged: _onAmPmChanged,
                compact: isKeyboardOpen,
                label: (i) => i == 0 ? '오전' : '오후',
                width: 64,
              ),
              const SizedBox(width: 8),
              // 시 휠 (1-12)
              _buildWheel(
                ctrl: _hourCtrl,
                count: 12,
                selected: _hour12 - 1,
                onChanged: _onHourWheelChanged,
                compact: isKeyboardOpen,
                label: (i) => (i + 1).toString().padLeft(2, '0'),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: TextStyle(color: Colors.white38, fontSize: 24),
                ),
              ),
              // 분 휠
              _buildWheel(
                ctrl: _minuteCtrl,
                count: 60,
                selected: _minute,
                onChanged: (i) => setState(() => _minute = i),
                compact: isKeyboardOpen,
                label: (i) => i.toString().padLeft(2, '0'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                TimeOfDay(hour: _hour, minute: _minute),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '완료',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
