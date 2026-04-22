import 'package:andone/model/todo_model.dart';
import 'package:andone/todo_detail_page/todo_detail_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andone/todo_detail_page/difficulty_slider.dart';
import 'package:andone/todo_detail_page/schedule_selector.dart';
import 'package:andone/todo_detail_page/repeat_selector.dart';
import 'package:andone/common/quest_section_card.dart';
import 'package:andone/common/quest_text_field.dart';
import 'package:andone/common/quest_header.dart';

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
  late DateTime _startDateTime;
  late DateTime _endDateTime;
  late RepeatType _repeat;
  late List<int> _repeatDays;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _contentController = TextEditingController(text: widget.todo.content);
    _difficulty = widget.todo.difficulty.toDouble();
    _startDateTime = widget.todo.startTime;
    _endDateTime = widget.todo.endTime;
    _repeat = RepeatType.values[widget.todo.repeat];
    _repeatDays = List<int>.from(widget.todo.repeatDays);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(todoDetailPageViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
              // 상단 액센트 라인
              Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.blue, Colors.transparent],
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: QuestHeader(
                  title: '퀘스트 상세',
                  badge: 'ACTIVE',
                  onBack: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: [
                    QuestSectionCard(
                      label: '퀘스트명',
                      child: QuestTextField(controller: _titleController, hint: '퀘스트 이름을 입력하세요'),
                    ),
                    const SizedBox(height: 12),
                    QuestSectionCard(
                      label: '상세 내용',
                      child: QuestTextField(controller: _contentController, hint: '퀘스트 내용을 기록하세요...', maxLines: 4),
                    ),
                    const SizedBox(height: 12),
                    QuestSectionCard(
                      label: '난이도',
                      child: DifficultySlider(
                        difficulty: _difficulty,
                        onChanged: (v) => setState(() => _difficulty = v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    QuestSectionCard(
                      label: _repeat != RepeatType.none ? '시작일 설정' : '일정 설정',
                      child: ScheduleSelector(
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
                    ),
                    const SizedBox(height: 12),
                    QuestSectionCard(
                      label: '반복 설정',
                      child: RepeatSelector(
                        value: _repeat,
                        repeatDays: _repeatDays,
                        onChanged: (v) => setState(() {
                          _repeat = v;
                          _repeatDays = [];
                        }),
                        onRepeatDaysChanged: (days) {
                          setState(() {
                            _repeatDays = days;
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
                            } else {
                              final today = DateTime.now();
                              _startDateTime = DateTime(
                                today.year, today.month, today.day,
                                _startDateTime.hour, _startDateTime.minute,
                              );
                              _endDateTime = DateTime(
                                today.year, today.month, today.day,
                                _endDateTime.hour, _endDateTime.minute,
                              );
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomBar(viewModel),
        ],
      ),
    );
  }

  Widget _buildBottomBar(dynamic viewModel) {
    return SafeArea(
      top: false,
      child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF2D2D2D),
                      title: const Text('삭제 확인', style: TextStyle(color: Colors.white)),
                      content: const Text('정말로 삭제하시겠습니까?',
                        style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소', style: TextStyle(color: Colors.white54)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('삭제',
                            style: TextStyle(color: Color(0xFFE74C3C))),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  await viewModel.deleteTodo(widget.todo.id);
                  if (context.mounted) Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE74C3C),
                  side: const BorderSide(color: Color(0xFFC0392B), width: 1.5),
                  backgroundColor: const Color(0x1AC0392B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('삭제',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (_endDateTime.isBefore(_startDateTime)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('종료 시간이 시작 시간보다 빠를 수 없습니다.')),
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
                    repeat: _repeat.index,
                    repeatDays: _repeatDays,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('퀘스트 저장',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

