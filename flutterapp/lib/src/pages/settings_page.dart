import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Configurações',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
    );
  }
}
