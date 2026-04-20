import 'package:andone/profile_page/profile_page_view_model.dart';
import 'package:andone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePageView extends ConsumerWidget {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('프로필', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFF2D2D2D),
              child: Icon(Icons.person, size: 48, color: Colors.white54),
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
            const SizedBox(height: 4),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _statRow(
                    '😊 기분',
                    '${user?.mood ?? 50} / ${user?.maxMood ?? 100}',
                    Colors.pinkAccent,
                  ),
                  const SizedBox(height: 12),
                  _statRow(
                    '🪙 골드',
                    '${user?.gold ?? 0}',
                    Colors.amber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 퀘스트 달성 진행도
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚔️ 퀘스트 달성',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (_) {
                      final total = user?.totalCompleted ?? 0;
                      // 다음 마일스톤 계산 (10, 20, 50, 100, 200, ...)
                      const milestones = [10, 20, 50, 100, 200, 500];
                      final nextMilestone = milestones.firstWhere(
                        (m) => m > total,
                        orElse: () => ((total ~/ 100) + 1) * 100,
                      );
                      final prevMilestone = milestones.lastWhere(
                        (m) => m <= total,
                        orElse: () => 0,
                      );
                      final progress = (total - prevMilestone) /
                          (nextMilestone - prevMilestone);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '총 $total개 완료',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '목표 $nextMilestone개',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: Colors.grey[700],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.greenAccent,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
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
