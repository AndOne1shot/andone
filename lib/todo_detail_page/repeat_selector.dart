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
    const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '반복 설정',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<RepeatType>(
                title: const Text('없음'),
                value: RepeatType.none,
                groupValue: value,
                onChanged: (v) => onChanged(v!),
                dense: true,
                contentPadding: EdgeInsets.zero,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
            ),
            Expanded(
              child: RadioListTile<RepeatType>(
                title: const Text('매일'),
                value: RepeatType.daily,
                groupValue: value,
                onChanged: (v) => onChanged(v!),
                dense: true,
                contentPadding: EdgeInsets.zero,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
            ),
            Expanded(
              child: RadioListTile<RepeatType>(
                title: const Text('매주'),
                value: RepeatType.weekly,
                groupValue: value,
                onChanged: (v) => onChanged(v!),
                dense: true,
                contentPadding: EdgeInsets.zero,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
            ),
          ],
        ),
        if (value == RepeatType.weekly) ...[
          const SizedBox(height: 8),
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
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blue : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dayLabels[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey,
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
