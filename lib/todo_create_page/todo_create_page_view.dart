import 'package:andone/todo_create_page/todo_create_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andone/common/difficulty_slider.dart';
import 'package:andone/common/schedule_selector.dart';
import 'package:andone/common/repeat_selector.dart';
import 'package:andone/common/quest_section_card.dart';
import 'package:andone/common/quest_text_field.dart';
import 'package:andone/common/quest_header.dart';
import 'package:andone/common/discard_dialog.dart';

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

  bool _hasChanges() {
    return _titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty ||
        _difficulty != 1 ||
        _repeat != RepeatType.none;
  }

  Future<void> _maybePop() async {
    if (!_hasChanges()) {
      if (context.mounted) Navigator.pop(context);
      return;
    }
    final discard = await showDiscardDialog(context);
    if (discard == true && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(todoCreatePageViewModelProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _maybePop();
      },
      child: Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
              SafeArea(
                bottom: false,
                child: QuestHeader(
                  title: '퀘스트 생성',
                  badge: 'NEW',
                  onBack: _maybePop,
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
    ));
  }

  Widget _buildBottomBar(dynamic viewModel) {
    return SafeArea(
      top: false,
      child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('제목을 입력해주세요')),
              );
              return;
            }
            if (_endDateTime.isBefore(_startDateTime)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('종료 시간이 시작 시간보다 빠를 수 없습니다.')),
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
            if (context.mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('퀘스트 생성',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ),
      ),
    ));
  }
}

