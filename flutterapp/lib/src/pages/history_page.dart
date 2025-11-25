import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/db.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Attempt> _attempts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DBHelper.getAttempts(limit: 200);
    if (!mounted) return;
    setState(() {
      _attempts = list;
      _loading = false;
    });
  }

  String _fmtDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showDetails(Attempt at) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Detalhes - ${_fmtDate(at.timestamp)}'),
          content: SizedBox(
            width: double.maxFinite,
            child: at.details == null
                ? Text(
                    'Acertos: ${at.correct} / ${at.total}\nPercentual: ${at.percent}%'
                    '${at.durationSeconds != null ? "\nDuração: ${at.durationSeconds}s" : ""}')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: at.details!.length + 1,
                    itemBuilder: (c, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                              'Resultado: ${at.correct}/${at.total} • ${at.percent}%'),
                        );
                      }
                      final d = at.details![i - 1];
                      final pt = d['pt'] ?? '';
                      final en = d['en'] ?? '';
                      final selected = d['selected'] ?? '';
                      final correct = d['correct'] ?? '';
                      final ok = selected == correct;
                      return ListTile(
                        dense: true,
                        title: Text(pt),
                        subtitle:
                            Text('Resposta: $selected • Correto: $correct'),
                        trailing: Icon(ok ? Icons.check_circle : Icons.cancel,
                            color: ok ? Colors.green : Colors.red),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fechar'))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_attempts.isEmpty) {
      return const Center(child: Text('Nenhum histórico ainda'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _attempts.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (ctx, i) {
        final at = _attempts[i];
        return ListTile(
          title: Text(_fmtDate(at.timestamp)),
          subtitle: Text('Acertos: ${at.correct} / ${at.total}'),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${at.percent}%',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (at.durationSeconds != null)
                Text('${at.durationSeconds}s',
                    style: const TextStyle(fontSize: 12)),
            ],
          ),
          onTap: () => _showDetails(at),
        );
      },
    );
  }
}
