// Todo 반복 설정 위젯. 없음 / 매일 / 매주 중 선택하며,
// 매주 선택 시 요일 선택 UI가 추가로 표시됨.
// RepeatType enum도 이 파일에서 export되므로 반복 관련 로직에서 함께 import해서 사용.
//
// 사용법:
//   RepeatSelector(
//     value: _repeatType,                           // RepeatType
//     onChanged: (type) => setState(() => _repeatType = type),
//     repeatDays: _repeatDays,                      // List<int>, 1=월~7=일
//     onRepeatDaysChanged: (days) => setState(() => _repeatDays = days),
//   )
import 'package:flutter/material.dart';

enum RepeatType { none, daily, weekly }

class RepeatSelector extends StatelessWidget {
  final RepeatType value;
  final ValueChanged<RepeatType> onChanged;
  final List<int> repeatDays;
  final ValueChanged<List<int>> onRepeatDaysChanged;

  const RepeatSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.repeatDays,
    required this.onRepeatDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    const opts = [
      {'icon': Icons.close, 'label': '없음'},
      {'icon': Icons.wb_sunny_outlined, 'label': '매일'},
      {'icon': Icons.calendar_month_outlined, 'label': '매주'},
    ];
    const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            final active = value.index == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(RepeatType.values[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(left: i == 0 ? 0 : 4, right: i == 2 ? 0 : 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: active ? Colors.blue.withOpacity(0.15) : const Color(0xFF1A1A1A),
                    border: Border.all(
                      color: active ? Colors.blue : Colors.white24,
                      width: active ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(opts[i]['icon'] as IconData,
                        color: active ? Colors.blue : Colors.white38, size: 22),
                      const SizedBox(height: 6),
                      Text(opts[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: active ? Colors.blue : Colors.white38,
                        )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        if (value == RepeatType.weekly) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = index + 1;
              final isSelected = repeatDays.contains(day);
              return GestureDetector(
                onTap: () {
                  final updated = List<int>.from(repeatDays);
                  if (isSelected) {
                    updated.remove(day);
                  } else {
                    updated.add(day);
                  }
                  onRepeatDaysChanged(updated);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blue : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.white24,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dayLabels[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
