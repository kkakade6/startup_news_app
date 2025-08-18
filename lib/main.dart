import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/env"); // DO NOT MOVE THIS FILE
  runApp(const ProNewsApp());
}

class ProNewsApp extends StatefulWidget {
  const ProNewsApp({super.key});

  @override
  State<ProNewsApp> createState() => _ProNewsAppState();
}

class _ProNewsAppState extends State<ProNewsApp> {
  bool _onboarded = false; // simple flag for MVP
  bool _signedIn = false;  // simulated sign-in

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'ProNews',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B3C5D)),
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black87),
          ),
        ),
        home: _onboarded
            ? const HomeScreen()
            : OnboardingScreen(
                onExplore: () => setState(() => _onboarded = true),
                onMockSignIn: () {
                  // Simulate sign-in success for MVP
                  setState(() {
                    _signedIn = true;
                    _onboarded = true;
                  });
                },
              ),
      ),
    );
  }
}
