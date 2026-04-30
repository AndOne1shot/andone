import 'package:flutter/material.dart';

Future<bool?> showDiscardDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: const Text(
        '변경사항이 있습니다',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        '저장하지 않고 나가시겠습니까?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('계속 편집', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('나가기', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );
}
