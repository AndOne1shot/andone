import 'package:andone/profile_page/profile_page_view_model.dart';
import 'package:andone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePageView extends ConsumerStatefulWidget {
  const ProfilePageView({super.key});

  @override
  ConsumerState<ProfilePageView> createState() => _ProfilePageViewState();
}

class _ProfilePageViewState extends ConsumerState<ProfilePageView> {
  late DateTime _currentMonth;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;
    final historyAsync = ref.watch(completedHistoryProvider(_currentMonth));

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // 이번 주 월~일 날짜 계산
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('프로필', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/image/character/my_pet_right.png',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              user?.nickname ?? '-',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // 스탯 카드
            _card(
              child: Column(
                children: [
                  _statRow(
                    '😊 기분',
                    '${user?.mood ?? 50} / ${user?.maxMood ?? 100}',
                    Colors.pinkAccent,
                  ),
                  const SizedBox(height: 12),
                  _statRow('🪙 골드', '${user?.gold ?? 0}', Colors.amber),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // // 퀘스트 달성 진행도
            // _card(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         '⚔️ 퀘스트 달성',
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 14,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       const SizedBox(height: 12),
            //       Builder(
            //         builder: (_) {
            //           final total = user?.totalCompleted ?? 0;
            //           const milestones = [10, 20, 50, 100, 200, 500];
            //           final nextMilestone = milestones.firstWhere(
            //             (m) => m > total,
            //             orElse: () => ((total ~/ 100) + 1) * 100,
            //           );
            //           final prevMilestone = milestones.lastWhere(
            //             (m) => m <= total,
            //             orElse: () => 0,
            //           );
            //           final progress =
            //               (total - prevMilestone) /
            //               (nextMilestone - prevMilestone);
            //           return Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                 children: [
            //                   Text(
            //                     '총 $total개 완료',
            //                     style: const TextStyle(
            //                       color: Colors.white70,
            //                       fontSize: 13,
            //                     ),
            //                   ),
            //                   Text(
            //                     '목표 $nextMilestone개',
            //                     style: const TextStyle(
            //                       color: Colors.white38,
            //                       fontSize: 12,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //               const SizedBox(height: 8),
            //               ClipRRect(
            //                 borderRadius: BorderRadius.circular(4),
            //                 child: LinearProgressIndicator(
            //                   value: progress.clamp(0.0, 1.0),
            //                   minHeight: 8,
            //                   backgroundColor: Colors.grey[700],
            //                   valueColor: const AlwaysStoppedAnimation<Color>(
            //                     Colors.greenAccent,
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           );
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 16),

            // 활동 기록
            historyAsync.when(
              data: (history) {
                // 이번 주 바 차트
                const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
                final weekCounts = weekDates.map((d) {
                  final key =
                      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                  return history[key] ?? 0;
                }).toList();
                final maxCount = weekCounts.reduce((a, b) => a > b ? a : b);

                // 이번 달 캘린더
                final firstDay = DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  1,
                );
                final lastDay = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                  0,
                ).day;
                final startWeekday = firstDay.weekday; // 1=월

                return _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 활동 기록',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 이번 주 바 차트
                      const Text(
                        '이번 주',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (i) {
                          final count = weekCounts[i];
                          final barHeight = maxCount == 0
                              ? 4.0
                              : (count / maxCount * 60).clamp(4.0, 60.0);
                          final isToday =
                              weekDates[i].day == now.day &&
                              weekDates[i].month == now.month;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$count',
                                style: TextStyle(
                                  color: count > 0
                                      ? Colors.white70
                                      : Colors.transparent,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 28,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? Colors.greenAccent
                                      : Colors.green[700],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dayLabels[i],
                                style: TextStyle(
                                  color: isToday
                                      ? Colors.white
                                      : Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // 월별 캘린더
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() {
                                _currentMonth = DateTime(
                                  _currentMonth.year,
                                  _currentMonth.month - 1,
                                );
                              });
                            },
                          ),
                          Text(
                            '${_currentMonth.year}년 ${_currentMonth.month}월',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              color:
                                  _currentMonth.year == now.year &&
                                      _currentMonth.month == now.month
                                  ? Colors.white24
                                  : Colors.white54,
                            ),
                            onPressed:
                                _currentMonth.year == now.year &&
                                    _currentMonth.month == now.month
                                ? null
                                : () {
                                    setState(() {
                                      _currentMonth = DateTime(
                                        _currentMonth.year,
                                        _currentMonth.month + 1,
                                      );
                                    });
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const ['월', '화', '수', '목', '금', '토', '일']
                            .map(
                              (d) => SizedBox(
                                width: 32,
                                child: Center(
                                  child: Text(
                                    d,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 6),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1,
                            ),
                        itemCount: (startWeekday - 1) + lastDay,
                        itemBuilder: (context, index) {
                          if (index < startWeekday - 1) return const SizedBox();
                          final day = index - (startWeekday - 1) + 1;
                          final dateStr =
                              '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                          final count = history[dateStr] ?? 0;
                          final isToday = dateStr == todayStr;
                          return Center(
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$day일 - ${count > 0 ? '$count개 달성' : '달성 없음'}',
                                    ),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: count > 0
                                      ? Colors.greenAccent.withOpacity(
                                          (count * 0.2).clamp(0.3, 1.0),
                                        )
                                      : Colors.transparent,
                                  border: isToday
                                      ? Border.all(
                                          color: Colors.white54,
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$day',
                                      style: TextStyle(
                                        color: count > 0
                                            ? Colors.white
                                            : Colors.white38,
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (isToday)
                                      const Text(
                                        'TODAY',
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 6,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('에러: $e'),
            ),
            const SizedBox(height: 16),

            // 로그아웃
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await ref
                      .read(profilePageViewModelProvider.notifier)
                      .signOut();
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
