import 'package:andone/main_page/home_tab_view_model.dart';
import 'package:andone/todo_create_page/todo_create_page_view.dart';
import 'package:andone/todo_detail_page/repeat_selector.dart';
import 'package:andone/todo_detail_page/todo_detail_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTabView extends ConsumerStatefulWidget {
  const HomeTabView({super.key});

  @override
  ConsumerState<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends ConsumerState<HomeTabView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _xAnim;
  late Animation<double> _yAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeTabViewModelProvider).checkDailyMoodDecrease();
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..repeat(reverse: true);

    _xAnim = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _yAnim = Tween<double>(begin: 0, end: 1).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoAsync = ref.watch(todoListProvider);
    final userAsync = ref.watch(userProvider);
    final viewModel = ref.read(homeTabViewModelProvider);
    final user = userAsync.value;

    String formatTime(DateTime time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    /// 반복 todo의 표시용 DateTime을 반환한다.
    /// - 저장된 날짜가 미래면 → 그대로 반환
    /// - 저장된 날짜가 오늘이거나 과거면 → 오늘 날짜 + 저장된 시간으로 교체
    DateTime effectiveTime(DateTime stored) {
      final storedDate = DateTime(stored.year, stored.month, stored.day);
      if (storedDate.isAfter(todayDate)) return stored;
      return DateTime(
        today.year,
        today.month,
        today.day,
        stored.hour,
        stored.minute,
      );
    }

    String getRemainingTime(DateTime startTime, DateTime endTime) {
      final now = DateTime.now();
      if (now.isAfter(endTime)) return "종료됨";
      final diff = startTime.difference(now);
      if (diff.isNegative) return "시작됨";
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (hours > 0) return "$hours시간 ${minutes}분 전";
      return "$minutes분 전";
    }

    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // 오늘 표시할 todo 필터링
    bool shouldShowTodo(todo) {
      // 반복 있음: 항상 표시 (수정/삭제 접근 가능하도록)
      if (todo.repeat != 0) return true;

      // 반복 없음: 오늘 날짜인 것만 표시
      final startDate = DateTime(
        todo.startTime.year,
        todo.startTime.month,
        todo.startTime.day,
      );
      return startDate == todayDate;
    }

    // 반복 todo 완료 여부 판단
    bool isCompletedToday(todo) {
      if (todo.repeat == 0) return todo.isCompleted;
      return todo.lastCompletedDate == todayStr;
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

    final mood = user?.mood ?? 50;
    final maxMood = user?.maxMood ?? 100;
    final moodRatio = mood / maxMood;

    // 기분 수치에 따른 이모지
    String getMoodEmoji() {
      if (moodRatio >= 0.8) return '😊';
      if (moodRatio >= 0.5) return '😐';
      if (moodRatio >= 0.2) return '😢';
      return '😫';
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
            // 상단 캐릭터 영역
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      // 닉네임 + 골드
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user?.nickname ?? 'My Pet',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${user?.gold ?? 0}',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 문어 캐릭터
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            final dy =
                                -8 * (1 - ((_yAnim.value - 0.5).abs() * 2));
                            final isRight =
                                _animController.status ==
                                AnimationStatus.forward;
                            return Align(
                              alignment: Alignment(
                                _xAnim.value,
                                0.6 + dy * 0.05,
                              ),
                              child: Image.asset(
                                isRight
                                    ? 'assets/image/character/my_pet_right.png'
                                    : 'assets/image/character/my_pet_left.png',
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 기분 바
                      Row(
                        children: [
                          Text(
                            getMoodEmoji(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '기분',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: moodRatio,
                                minHeight: 8,
                                backgroundColor: Colors.grey[700],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  moodRatio >= 0.5
                                      ? Colors.pinkAccent
                                      : Colors.blueGrey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$mood/$maxMood',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 Todo 리스트 영역
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        data: (todos) {
                          final filtered = todos.where(shouldShowTodo).toList();
                          if (filtered.isEmpty) {
                            return const Center(child: Text("오늘의 퀘스트가 없습니다!"));
                          }
                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final todo = filtered[index];
                              final completed = isCompletedToday(todo);
                              return Card(
                                elevation: 0,
                                color: Colors.grey[100],
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TodoDetailPageView(todo: todo),
                                      ),
                                    );
                                  },
                                  title: Row(
                                    children: [
                                      Text(
                                        todo.title,
                                        style: TextStyle(
                                          decoration: completed
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: completed
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                      if (todo.repeat != 0) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            getRepeatLabel(
                                              todo.repeat,
                                              todo.repeatDays,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Text(
                                    "${formatTime(todo.startTime)} ~ ${formatTime(todo.endTime)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 매주 반복이고 오늘이 해당 요일이 아니면 시간 숨김
                                      if (!(todo.repeat ==
                                              RepeatType.weekly.index &&
                                          !todo.repeatDays.contains(
                                            today.weekday,
                                          ))) ...[
                                        const Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          getRemainingTime(
                                            todo.repeat != 0
                                                ? effectiveTime(todo.startTime)
                                                : todo.startTime,
                                            todo.repeat != 0
                                                ? effectiveTime(todo.endTime)
                                                : todo.endTime,
                                          ),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      IconButton(
                                        icon: Icon(
                                          completed
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: completed
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        onPressed: completed
                                            ? null
                                            : () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('퀘스트 완료'),
                                                    content: const Text(
                                                      '완료하면 다시 취소할 수 없어요.\n정말 완료할까요?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text('취소'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          '완료',
                                                          style: TextStyle(
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await viewModel.toggleTodo(
                                                    todo.id,
                                                    completed,
                                                    difficulty: todo.difficulty,
                                                    repeat: todo.repeat,
                                                  );
                                                }
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
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
