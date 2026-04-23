import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

// earlier this was MiniCartApp extends StatelessWidget
// before I implemented dark mode
// since dark mode is stateful ie it changes, hence...
class MiniCartApp extends StatefulWidget {
  const MiniCartApp({super.key});

  @override
  State<MiniCartApp> createState() => _MiniCartAppState();
}

class _MiniCartAppState extends State<MiniCartApp> {
  final _storageService = StorageService();
  bool _isDarkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final isDarkModeEnabled = await _storageService.isDarkModeEnabled();
    if (!mounted) {
      return;
    }

    setState(() {
      _isDarkModeEnabled = isDarkModeEnabled;
    });
  }

  Future<void> _setDarkModeEnabled(bool value) async {
    setState(() {
      _isDarkModeEnabled = value;
    });

    await _storageService.saveDarkModeEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // LAB 10: Final app integration entry point
      // This is where all features come together as one complete demo app
      title: 'MiniCart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>(
        // LAB 9: FirebaseAuth session stream decides login/home at startup.
        // If a user session exists, app goes to home; otherwise it stays on login.
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }

          if (snapshot.data != null) {
            return HomeScreen(
              isDarkModeEnabled: _isDarkModeEnabled,
              onThemeModeChanged: _setDarkModeEnabled,
            );
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
