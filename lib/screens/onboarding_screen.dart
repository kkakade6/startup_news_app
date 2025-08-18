import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onExplore;
  final VoidCallback onMockSignIn;

  const OnboardingScreen({
    super.key,
    required this.onExplore,
    required this.onMockSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.trending_up, // Finance
      Icons.memory,      // Tech
      Icons.store,       // Business
      Icons.public,      // Markets
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ProNews',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
              'Your 5-minute business briefing.\nSwipe. Skim. Stay ahead.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),

            const Text(
              'Pick your focus (optional)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: icons
                  .map((i) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(i, size: 28),
                      ))
                  .toList(),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onMockSignIn,
                child: const Text('Sign in with Google'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onExplore,
                child: const Text('Explore First'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
