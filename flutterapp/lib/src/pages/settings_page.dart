import 'package:flutter/cupertino.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        const Center(
          child: Text('Configurações',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Notificações'),
            CupertinoSwitch(
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v)),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Modo escuro'),
            CupertinoSwitch(
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v)),
          ],
        ),
      ],
    );
  }
}
