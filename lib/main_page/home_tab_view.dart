import 'package:andone/main_page/main_page_view_model.dart';
import 'package:andone/todo_create_page/todo_create_page_view.dart';
import 'package:andone/todo_detail_page/repeat_selector.dart';
import 'package:andone/todo_detail_page/todo_detail_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTabView extends ConsumerWidget {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoAsync = ref.watch(todoListProvider);
    final monsterAsync = ref.watch(monsterProvider);
    final userAsync = ref.watch(userProvider);
    final viewModel = ref.read(mainPageViewModelProvider);
    final user = userAsync.value;

    String formatTime(DateTime time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    }

    String getRepeatLabel(int repeat, List<int> repeatDays) {
      const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
      if (repeat == RepeatType.daily.index) return '매일';
      if (repeat == RepeatType.weekly.index && repeatDays.isNotEmpty) {
        final days = repeatDays.map((d) => dayLabels[d - 1]).join('·');
        return '매주 $days';
      }
      return '';
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
                      // 스탯 영역 (HP, EXP)
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
                      // 캐릭터 vs 몬스터 영역
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 22),
                                Image.asset(
                                  "assets/image/character/test_character_1.png",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 18),
                              ],
                            ),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
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
                                      title: Row(
                                        children: [
                                          Text(
                                            todo.title,
                                            style: TextStyle(
                                              decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                              color: todo.isCompleted ? Colors.grey : Colors.black,
                                            ),
                                          ),
                                          if (todo.repeat != 0) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                getRepeatLabel(todo.repeat, todo.repeatDays),
                                                style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ],
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
                                          Text(getRemainingTime(todo.startTime), style: const TextStyle(fontSize: 12)),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(
                                              todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                              color: todo.isCompleted ? Colors.green : Colors.grey,
                                            ),
                                            onPressed: todo.isCompleted
                                                ? null
                                                : () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text('퀘스트 완료'),
                                                        content: const Text('완료하면 다시 취소할 수 없어요.\n정말 완료할까요?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, false),
                                                            child: const Text('취소'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, true),
                                                            child: const Text('완료', style: TextStyle(color: Colors.green)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      await viewModel.toggleTodo(
                                                        todo.id,
                                                        todo.isCompleted,
                                                        difficulty: todo.difficulty,
                                                      );
                                                    }
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
