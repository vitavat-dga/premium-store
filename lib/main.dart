import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const PremiumApp());
}

class PremiumApp extends StatefulWidget {
  const PremiumApp({super.key});

  @override
  State<PremiumApp> createState() => _PremiumAppState();
}

class _PremiumAppState extends State<PremiumApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'Premium Store',
        theme: buildAppTheme(),
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
      ),
    );
  }
}
