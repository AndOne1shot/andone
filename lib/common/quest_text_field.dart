// [공통 위젯] QuestTextField
// 퀘스트 생성/상세 페이지에서 사용하는 다크 테마 텍스트 입력 필드
//
// 구성 요소:
// - controller : 텍스트 값을 읽고 쓰기 위한 컨트롤러
// - hint       : 입력 전 표시되는 안내 문구
// - maxLines   : 줄 수 (기본 1줄, 상세내용은 4줄로 사용)
// - 테두리 상태 : 기본(white24) / 포커스(blue) 로 구분

import 'package:flutter/material.dart';

class QuestTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const QuestTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        // 기본 테두리
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        // 비활성 테두리
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        // 포커스 테두리
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
