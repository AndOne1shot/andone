import 'package:andone/main_page/main_page_view_model.dart';
import 'package:andone/todo_create_page/todo_create_page_view.dart';
import 'package:andone/todo_detail_page/todo_detail_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPageView extends ConsumerWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 데이터 구독 (watch) - DB 변경 시 자동 리빌드
    final todoAsync = ref.watch(todoListProvider);
    final monsterAsync = ref.watch(monsterProvider);
    // 2. 뷰모델 가져오기 (read) - 함수 호출용
    final viewModel = ref.read(mainPageViewModelProvider);

    // 시작시간, 종료시간 hh:mm 형식으로 변환
    String _formatTime(DateTime time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    }

    // 시작시간까지 남은 시간 계산
    String _getRemainingTime(DateTime startTime) {
      final now = DateTime.now();
      final diff = startTime.difference(now);

      if (diff.isNegative) {
        return "시작됨"; // 이미 시작
      }

      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;

      if (hours > 0) {
        return "$hours시간 ${minutes}분 전";
      } else {
        return "$minutes분 전";
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: 퀘스트 등록 페이지로 이동
          print("퀘스트 추가 버튼 클릭");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodoCreatePageView()),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 20%: 캐릭터와 몬스터 영역
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 내 캐릭터
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 30),
                          Image.asset(
                            "assets/image/character/test_character.png",
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                          const Text(
                            "My Hero",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      // 상대 몬스터
                      monsterAsync.when(
                        data: (monsters) {
                          if (monsters.isEmpty) return const Text("몬스터가 없습니다.");
                          final monster = monsters.first;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 몬스터의 현재 체력 / 총 체력 text
                              Text(
                                '${monster.hp} / ${monster.maxHp}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // 몬스터 체력바
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
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.red,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Image.asset(
                                // ID를 활용해 동적으로 경로 생성
                                "assets/image/monster/monster_${monster.monsterId}.png",
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                                // 이미지 파일이 없을 경우를 대비한 에러 처리
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.help,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                              ),
                              Text(
                                monster.monsterName, // "Monster" 대신 실제 이름 표시
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (err, stack) => Text("에러 발생: $err"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 80%: To-do List 영역
            Expanded(
              flex: 8,
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
                                        // 상세 페이지로 데이터 전달
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TodoDetailPageView(todo: todo),
                                          ),
                                        );
                                      },
                                      // 제목
                                      title: Text(
                                        todo.title,
                                        style: TextStyle(
                                          decoration: todo.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: todo.isCompleted
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                      // 시작시간 ~ 종료시간
                                      subtitle: Text(
                                        "${_formatTime(todo.startTime)} ~ ${_formatTime(todo.endTime)}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // 남은 시간 표시
                                              const Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                _getRemainingTime(
                                                  todo.startTime,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          // 완료 버튼
                                          IconButton(
                                            icon: Icon(
                                              todo.isCompleted
                                                  ? Icons.check_circle
                                                  : Icons
                                                        .radio_button_unchecked,
                                              color: todo.isCompleted
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                            onPressed: () async {
                                              await viewModel.toggleTodo(
                                                todo.id,
                                                todo.isCompleted,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        // 데이터를 로딩 중일 때
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        // 에러가 발생했을 때
                        error: (err, stack) =>
                            Center(child: Text("에러 발생: $err")),
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
