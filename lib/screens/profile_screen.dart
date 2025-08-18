import 'package:flutter/material.dart';
import '../providers/app_state.dart';

class ProfileScreen extends StatelessWidget {
  final AppState appState;
  const ProfileScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final dailyGoal = 10;
    final pct = (appState.todayCount / dailyGoal).clamp(0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reading Habit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text('Consistency Score: ${(pct * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: pct.toDouble()),
            const SizedBox(height: 24),
            Text('Streak: ${appState.streakDays} day(s)'),
            const SizedBox(height: 24),
            const Text(
              'Pro Plan (soon):\n• Morning Daily Digest\n• Offline mode\n• Export bookmarks as PDF',
            ),
          ],
        ),
      ),
    );
  }
}
