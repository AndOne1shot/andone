// [공통 위젯] QuestSectionCard
// 퀘스트 생성/상세 페이지에서 각 입력 섹션을 감싸는 카드 컨테이너
//
// 구성 요소:
// - 좌측 블루 수직 바 + label 텍스트 : 섹션 이름 표시 (예: '퀘스트명', '난이도')
// - child : 섹션 안에 들어갈 실제 입력 위젯 (텍스트필드, 슬라이더 등)

import 'package:flutter/material.dart';

class QuestSectionCard extends StatelessWidget {
  final String label;
  final Widget child;
  const QuestSectionCard({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 섹션 라벨 (좌측 수직 바 + 텍스트)
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 섹션 콘텐츠
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
