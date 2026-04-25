import 'package:andone/equipment_page/equipment_page_view.dart';
import 'package:andone/main_page/home_tab_view.dart';
import 'package:andone/profile_page/profile_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0; // 초기화면(HomeTabView())

  void setIndex(int index) => state = index;
}

final _tabIndexProvider = NotifierProvider.autoDispose<_TabIndexNotifier, int>(
  _TabIndexNotifier.new,
);

class MainPageView extends ConsumerWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(_tabIndexProvider);

    final tabs = const [HomeTabView(), EquipmentPageView(), ProfilePageView()];

    return Scaffold(
      body: tabs[tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex,
        onTap: (index) => ref.read(_tabIndexProvider.notifier).setIndex(index),
        backgroundColor: const Color(0xFF2D2D2D),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: '장비'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}
