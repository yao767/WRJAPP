import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_info.dart';
import 'pages/home_shell.dart';
import 'pages/login_page.dart';
import 'pages/splash_page.dart';
import 'state/app_state.dart';

void main() {
  runApp(const GuardianApp());
}

class GuardianApp extends StatelessWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: appProjectName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black.withOpacity(0.55),
          ),
        ),
        home: const SplashPage(next: AuthGate()),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.isLoggedIn) {
      return const LoginPage();
    }
    return const HomeShell();
  }
}
