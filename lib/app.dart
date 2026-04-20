import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
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
      home: StreamBuilder<User?>(
        // LAB 9: FirebaseAuth session stream decides login/home at startup.
        // If a user session exists, app goes to home; otherwise it stays on login.
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }

          if (snapshot.data != null) {
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
