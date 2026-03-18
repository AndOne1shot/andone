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
    final viewModel = ref.read(todoCreateViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("퀘스트 생성")),
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
              initialStartTime: _startDateTime,
              initialEndTime: _endDateTime,
              onChanged: (start, end) {
                _startDateTime = start;
                _endDateTime = end;
              },
            ),

            const SizedBox(height: 20),

            // 반복
            RepeatSelector(
              value: _repeat,
              onChanged: (v) {
                setState(() {
                  _repeat = v;
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
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("퀘스트 생성"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
