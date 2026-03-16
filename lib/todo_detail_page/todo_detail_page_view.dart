import 'package:andone/model/todo_model.dart';
import 'package:andone/todo_detail_page/todo_detail_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andone/todo_detail_page/difficulty_slider.dart';
import 'package:andone/todo_detail_page/schedule_selector.dart';

class TodoDetailPageView extends ConsumerStatefulWidget {
  final TodoModel todo;

  const TodoDetailPageView({super.key, required this.todo});

  @override
  ConsumerState<TodoDetailPageView> createState() => _TodoDetailPageViewState();
}

class _TodoDetailPageViewState extends ConsumerState<TodoDetailPageView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late double _difficulty;

  // 날짜 결과만 저장
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.todo.title);
    _contentController = TextEditingController(text: widget.todo.content);

    _difficulty = widget.todo.difficulty.toDouble();

    _startDateTime = widget.todo.startTime;
    _endDateTime = widget.todo.endTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(todoDetailViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('퀘스트 상세 정보'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '제목',
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),

            const SizedBox(height: 20),

            // 상세내용 입력
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '상세내용',
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),

            const SizedBox(height: 25),

            // 일정 설정 (완전 분리)
            ScheduleSelector(
              initialStartTime: widget.todo.startTime,
              initialEndTime: widget.todo.endTime,
              onChanged: (start, end) {
                _startDateTime = start;
                _endDateTime = end;
              },
            ),

            const SizedBox(height: 25),

            // 난이도 설정
            DifficultySlider(
              difficulty: _difficulty,
              onChanged: (value) {
                setState(() {
                  _difficulty = value;
                });
              },
            ),

            const Spacer(),

            // 하단 버튼 (삭제 / 저장)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await viewModel.deleteTodo(widget.todo.id);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Text('삭제'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // 시간 검증
                      if (_endDateTime.isBefore(_startDateTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("종료 시간이 시작 시간보다 빠를 수 없습니다."),
                          ),
                        );
                        return;
                      }

                      await viewModel.updateTodo(
                        docId: widget.todo.id,
                        newTitle: _titleController.text,
                        newContent: _contentController.text,
                        difficulty: _difficulty.round(),
                        startTime: _startDateTime,
                        endTime: _endDateTime,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Text('저장'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
