// 로그인 후 메인화면 진입 전 3초 로딩 오버레이.
// MainPageView 위에 덮어씌우는 방식으로 동작 — Navigator 조작 없음.
// Firestore 데이터가 로드되기 전 캐릭터 깜박임 방지가 목적.
// 3초 후 자동으로 사라지며 뒤에 준비된 MainPageView가 노출됨.
import 'dart:async';

import 'package:andone/main_page/main_page_view.dart';
import 'package:flutter/material.dart';

class MainWithLoading extends StatefulWidget {
  const MainWithLoading({super.key});

  @override
  State<MainWithLoading> createState() => _MainWithLoadingState();
}

class _MainWithLoadingState extends State<MainWithLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  bool _showLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _fadeAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showLoading = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 뒤에서 미리 로드되는 메인 페이지
        const MainPageView(),
        // 3초간 덮어씌우는 로딩 오버레이
        if (_showLoading)
          Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Image.asset(
                      'assets/image/character/my_pet_right.png',
                      width: 96,
                      height: 128,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
