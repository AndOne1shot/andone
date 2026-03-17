import 'package:flutter/material.dart';

enum RepeatType { none, daily, weekly }

class RepeatSelector extends StatelessWidget {
  final RepeatType value;
  final ValueChanged<RepeatType> onChanged;

  const RepeatSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              ),
            ),
          ],
        ),
      ],
    );
  }
}
