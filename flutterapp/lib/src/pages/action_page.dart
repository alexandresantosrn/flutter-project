import 'package:flutter/cupertino.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({super.key});

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Ação',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Text('Executada $_count vezes'),
        const SizedBox(height: 12),
        CupertinoButton.filled(
          child: const Text('Executar Ação'),
          onPressed: () => setState(() => _count++),
        ),
      ]),
    );
  }
}
