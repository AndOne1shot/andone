import 'package:flutter/material.dart';

class DifficultySlider extends StatelessWidget {
  final double difficulty;
  final ValueChanged<double> onChanged;

  const DifficultySlider({
    super.key,
    required this.difficulty,
    required this.onChanged,
  });

  Color getDifficultyColor(double value) {
    switch (value.round()) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.cyan;
      case 3:
        return Colors.green;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getDifficultyText(double value) {
    switch (value.round()) {
      case 1:
        return '매우 쉬움';
      case 2:
        return '쉬움';
      case 3:
        return '보통';
      case 4:
        return '어려움';
      case 5:
        return '매우 어려움';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '난이도',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: difficulty,
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: getDifficultyColor(difficulty),
                onChanged: onChanged,
              ),
            ),
            Text(
              '${difficulty.round()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Center(
          child: Text(
            getDifficultyText(difficulty),
            style: TextStyle(
              color: getDifficultyColor(difficulty),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
