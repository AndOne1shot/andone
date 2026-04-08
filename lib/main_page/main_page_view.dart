import 'package:andone/login_page/login_page_view_model.dart';
import 'package:andone/main_page/main_page_view_model.dart';
import 'package:andone/todo_create_page/todo_create_page_view.dart';
import 'package:andone/todo_detail_page/todo_detail_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPageView extends ConsumerWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoAsync = ref.watch(todoListProvider);
    final monsterAsync = ref.watch(monsterProvider);
    final userAsync = ref.watch(userProvider);
    final viewModel = ref.read(mainPageViewModelProvider);

    String formatTime(DateTime time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    }

    String getRemainingTime(DateTime startTime) {
      final now = DateTime.now();
      final diff = startTime.difference(now);
      if (diff.isNegative) return "시작됨";
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (hours > 0) return "$hours시간 ${minutes}분 전";
      return "$minutes분 전";
    }

    final user = userAsync.value;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodoCreatePageView()),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 배틀 영역
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // ── 스탯 영역 (HP, EXP) ──
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Lv.${user?.level ?? 1}  ${user?.nickname ?? 'My Hero'}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // HP 바
                          Row(
                            children: [
                              const SizedBox(
                                width: 28,
                                child: Text("HP", style: TextStyle(color: Colors.white70, fontSize: 10)),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (user?.hp ?? 100) / (user?.maxHp ?? 100),
                                    minHeight: 7,
                                    backgroundColor: Colors.grey[700],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 52,
                                child: Text(
                                  "${user?.hp ?? 100}/${user?.maxHp ?? 100}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // EXP 바
                          Row(
                            children: [
                              const SizedBox(
                                width: 28,
                                child: Text("EXP", style: TextStyle(color: Colors.white70, fontSize: 10)),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (user?.exp ?? 0) / (user?.maxExp ?? 100),
                                    minHeight: 7,
                                    backgroundColor: Colors.grey[700],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 52,
                                child: Text(
                                  "${user?.exp ?? 0}/${user?.maxExp ?? 100}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24, height: 14),
                        ],
                      ),
                      // ── 캐릭터 vs 몬스터 영역 ──
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 내 캐릭터
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 몬스터의 HP텍스트 + HP바 높이만큼 여백 맞춤
                                const SizedBox(height: 22),
                                Image.asset(
                                  "assets/image/character/test_character.png",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                                // 몬스터 이름 텍스트 높이 맞춤
                                const SizedBox(height: 18),
                              ],
                            ),
                            // 몬스터
                            monsterAsync.when(
                              data: (monsters) {
                                if (monsters.isEmpty) return const Text("몬스터가 없습니다.", style: TextStyle(color: Colors.white));
                                final monster = monsters.first;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${monster.hp} / ${monster.maxHp}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: 80,
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: monster.hp / monster.maxHp,
                                            minHeight: 6,
                                            backgroundColor: Colors.grey[700],
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      "assets/image/monster/monster_${monster.monsterId}.png",
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.help, size: 80, color: Colors.white),
                                    ),
                                    Text(
                                      monster.monsterName,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (err, stack) => Text("에러: $err"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 Todo 리스트 영역
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      "오늘의 퀘스트 (To-do)",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: todoAsync.when(
                        data: (todos) => todos.isEmpty
                            ? const Center(child: Text("오늘의 퀘스트가 없습니다!"))
                            : ListView.builder(
                                itemCount: todos.length,
                                itemBuilder: (context, index) {
                                  final todo = todos[index];
                                  return Card(
                                    elevation: 0,
                                    color: Colors.grey[100],
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TodoDetailPageView(todo: todo),
                                          ),
                                        );
                                      },
                                      title: Text(
                                        todo.title,
                                        style: TextStyle(
                                          decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                          color: todo.isCompleted ? Colors.grey : Colors.black,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "${formatTime(todo.startTime)} ~ ${formatTime(todo.endTime)}",
                                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                          const SizedBox(width: 2),
                                          Text(
                                            getRemainingTime(todo.startTime),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(
                                              todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                              color: todo.isCompleted ? Colors.green : Colors.grey,
                                            ),
                                            onPressed: () async {
                                              await viewModel.toggleTodo(todo.id, todo.isCompleted);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text("에러 발생: $err")),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 로그아웃 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          await ref.read(loginPageViewModelProvider.notifier).signOut();
                        },
                        child: const Text('로그아웃'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
