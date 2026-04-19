import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

class MiniCartApp extends StatelessWidget {
  const MiniCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // LAB 10: Final app integration entry point
      // This is where all features come together as one complete demo app
      title: 'MiniCart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: FutureBuilder<bool>(
        // LAB 9: Read saved login state from local storage on startup
        // This avoids asking the user to log in again every time the app opens
        future: StorageService().isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _SplashScreen();
          }

          if (snapshot.data == true) {
            return const HomeScreen();
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
