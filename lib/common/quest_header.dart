// [공통 위젯] QuestHeader
// 퀘스트 생성/상세 페이지 상단에 표시되는 헤더
//
// 구성 요소:
// - 뒤로가기 버튼 : 이전 페이지로 돌아가는 아이콘 버튼 (onBack 콜백 호출)
// - 'QUEST LOG' 서브타이틀 : 고정 텍스트, 블루 컬러로 섹션 컨텍스트 표시
// - title : 페이지 이름 (예: '퀘스트 생성', '퀘스트 상세')
// - badge : 우측 상태 배지 텍스트 (예: 'NEW', 'ACTIVE')

import 'package:flutter/material.dart';

class QuestHeader extends StatelessWidget {
  final String title;
  final String badge;
  final VoidCallback onBack;
  const QuestHeader({
    super.key,
    required this.title,
    required this.badge,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // 뒤로가기 버튼
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white70, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          // 서브타이틀 + 페이지 타이틀
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('QUEST LOG',
                style: TextStyle(
                  fontSize: 10, color: Colors.blue,
                  letterSpacing: 2, fontWeight: FontWeight.w700)),
              Text(title,
                style: const TextStyle(
                  fontSize: 18, color: Colors.white,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ],
          ),
          const Spacer(),
          // 상태 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge,
              style: const TextStyle(
                fontSize: 11, color: Colors.blue,
                fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}
