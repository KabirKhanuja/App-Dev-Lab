import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.isDarkModeEnabled,
    required this.onThemeModeChanged,
  });

  final bool isDarkModeEnabled;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkModeEnabled;

  @override
  void initState() {
    super.initState();
    _isDarkModeEnabled = widget.isDarkModeEnabled;
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _isDarkModeEnabled = value;
    });

    widget.onThemeModeChanged(value);
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark mode'),
              // subtitle: const Text('Use the app in a darker color scheme.'),
              trailing: Switch(
                value: _isDarkModeEnabled,
                onChanged: _toggleDarkMode,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              // subtitle: const Text('Sign out of your MiniCart account.'),
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
