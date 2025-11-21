import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  List<String> _sampleItems() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final t = now.subtract(Duration(minutes: i * 15));
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} — Evento ${i + 1}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _sampleItems();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(items[i]),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.info),
            onPressed: () => showCupertinoDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                title: const Text('Detalhes'),
                content: Text('Detalhes do item: ${items[i]}'),
                actions: [
                  CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop())
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
