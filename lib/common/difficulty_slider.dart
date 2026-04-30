// Todo 난이도를 1~5 슬라이더로 선택하는 위젯.
// 난이도에 따라 색상(초록→빨강)과 별점, 텍스트 레이블이 변경됨.
//
// 사용법:
//   DifficultySlider(
//     difficulty: _difficulty,       // double, 1.0~5.0
//     onChanged: (val) => setState(() => _difficulty = val),
//   )
import 'package:flutter/material.dart';

class DifficultySlider extends StatelessWidget {
  final double difficulty;
  final ValueChanged<double> onChanged;

  const DifficultySlider({
    super.key,
    required this.difficulty,
    required this.onChanged,
  });

  Color _color(double v) {
    if (v <= 1) return const Color(0xFF2ECC71);
    if (v <= 2) return const Color(0xFF3498DB);
    if (v <= 3) return const Color(0xFFE8B84B);
    if (v <= 4) return const Color(0xFFE67E22);
    return const Color(0xFFE74C3C);
  }

  String _label(double v) {
    switch (v.round()) {
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
    final color = _color(difficulty);
    return Column(
      children: [
        Row(
          children: [
            const Text(
              '쉬움',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF2ECC71),
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 18,
                  ),
                  activeTrackColor: color,
                  inactiveTrackColor: const Color(0xFF3A3A3A),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0x30FFFFFF),
                ),
                child: Slider(
                  value: difficulty,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: onChanged,
                ),
              ),
            ),
            const Text(
              '어려움',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFE74C3C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final active = i < difficulty.round();
            return Text(
              '★',
              style: TextStyle(
                fontSize: 20,
                color: active ? color : Colors.white12,
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          '${_label(difficulty)}  Lv.${difficulty.round()}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
