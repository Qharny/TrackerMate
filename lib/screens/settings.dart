import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          trailing: Switch(
            value: true,
            onChanged: (bool value) {
              // Handle notification toggle
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Privacy'),
          onTap: () {
            // Navigate to Privacy settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          onTap: () {
            // Navigate to Help & Support
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () {
            // Navigate to About page
          },
        ),
      ],
    );
  }
}
