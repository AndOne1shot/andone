import 'package:andone/todo_create_page/todo_create_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andone/todo_detail_page/difficulty_slider.dart';
import 'package:andone/todo_detail_page/schedule_selector.dart';
import 'package:andone/todo_detail_page/repeat_selector.dart';

class TodoCreatePageView extends ConsumerStatefulWidget {
  const TodoCreatePageView({super.key});

  @override
  ConsumerState<TodoCreatePageView> createState() => _TodoCreatePageViewState();
}

class _TodoCreatePageViewState extends ConsumerState<TodoCreatePageView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  double _difficulty = 1;

  late DateTime _startDateTime;
  late DateTime _endDateTime;

  late RepeatType _repeat;
  List<int> _repeatDays = [];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _contentController = TextEditingController();

    _startDateTime = DateTime.now();
    _endDateTime = DateTime.now().add(const Duration(hours: 1));
    _repeat = RepeatType.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(todoCreatePageViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("퀘스트 생성"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 제목
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "제목",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 내용
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "상세내용",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 난이도
            DifficultySlider(
              difficulty: _difficulty,
              onChanged: (v) {
                setState(() {
                  _difficulty = v;
                });
              },
            ),

            const SizedBox(height: 20),

            // 일정
            ScheduleSelector(
              key: ValueKey(_startDateTime),
              initialStartTime: _startDateTime,
              initialEndTime: _endDateTime,
              isRepeat: _repeat != RepeatType.none,
              repeatDays: _repeatDays,
              onChanged: (start, end) {
                _startDateTime = start;
                _endDateTime = end;
              },
            ),

            const SizedBox(height: 20),

            // 반복
            RepeatSelector(
              value: _repeat,
              repeatDays: _repeatDays,
              onChanged: (v) {
                setState(() {
                  _repeat = v;
                  _repeatDays = [];
                });
              },
              onRepeatDaysChanged: (days) {
                setState(() {
                  _repeatDays = days;
                  // 요일 바뀔 때마다 오늘부터 가장 가까운 요일로 시작일 재계산
                  if (days.isNotEmpty) {
                    DateTime next = DateTime.now();
                    while (!days.contains(next.weekday)) {
                      next = next.add(const Duration(days: 1));
                    }
                    _startDateTime = DateTime(
                      next.year, next.month, next.day,
                      _startDateTime.hour, _startDateTime.minute,
                    );
                    _endDateTime = DateTime(
                      next.year, next.month, next.day,
                      _endDateTime.hour, _endDateTime.minute,
                    );
                  }
                });
              },
            ),

            const Spacer(),

            // 생성 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("제목을 입력해주세요")));
                    return;
                  }

                  if (_endDateTime.isBefore(_startDateTime)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("종료 시간이 시작 시간보다 빠를 수 없습니다."),
                      ),
                    );
                    return;
                  }

                  await viewModel.createTodo(
                    title: _titleController.text,
                    content: _contentController.text,
                    difficulty: _difficulty.round(),
                    startTime: _startDateTime,
                    endTime: _endDateTime,
                    repeat: _repeat.index,
                    repeatDays: _repeatDays,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "퀘스트 생성",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
