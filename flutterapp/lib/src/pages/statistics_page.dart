import 'package:flutter/material.dart';
import '../utils/db.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _loading = true;
  List<Attempt> _attempts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await DBHelper.initDb();
    final list = await DBHelper.getAttempts(limit: 1000);
    if (!mounted) return;
    setState(() {
      _attempts = list;
      _loading = false;
    });
  }

  String _fmtDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  int get totalAttempts => _attempts.length;

  int get bestPercent {
    if (_attempts.isEmpty) return 0;
    return _attempts.map((a) => a.percent).reduce((v, e) => v > e ? v : e);
  }

  int get avgPercent {
    if (_attempts.isEmpty) return 0;
    final sum = _attempts.map((a) => a.percent).reduce((v, e) => v + e);
    return (sum / _attempts.length).round();
  }

  int? get avgDuration {
    final list = _attempts
        .where((a) => a.durationSeconds != null)
        .map((a) => a.durationSeconds!)
        .toList();
    if (list.isEmpty) return null;
    final sum = list.reduce((v, e) => v + e);
    return (sum / list.length).round();
  }

  double get last7DaysAvg {
    if (_attempts.isEmpty) return 0;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final list = _attempts.where((a) => a.timestamp.isAfter(cutoff)).toList();
    if (list.isEmpty) return 0;
    final sum = list.map((a) => a.percent).reduce((v, e) => v + e);
    return sum / list.length;
  }

  int currentStreakDays() {
    if (_attempts.isEmpty) return 0;
    final dates = _attempts
        .map((a) =>
            DateTime(a.timestamp.year, a.timestamp.month, a.timestamp.day))
        .toSet();
    var streak = 0;
    var day = DateTime.now();
    while (true) {
      final d = DateTime(day.year, day.month, day.day);
      if (dates.contains(d)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Future<void> _clearHistory() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text('Tem certeza que deseja apagar todo o histórico?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Apagar')),
        ],
      ),
    );
    if (ok == true) {
      await DBHelper.clearAttempts();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_attempts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nenhuma tentativa registrada ainda',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Atualizar')),
          ],
        ),
      );
    }

    final streak = currentStreakDays();
    final avgDur = avgDuration;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('Tentativas',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('$totalAttempts',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('Média de acerto',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('$avgPercent%',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                            'Últimos 7 dias: ${last7DaysAvg.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('Melhor', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('$bestPercent%',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('Duração média',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(avgDur == null ? '-' : '${avgDur}s',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Streak: $streak dias',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Última tentativa'),
              subtitle: Text(_fmtDate(_attempts.first.timestamp)),
              trailing: Text('${_attempts.first.percent}%',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Tentativas recentes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._attempts.take(50).map((at) {
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: at.percent >= 70
                    ? Colors.green
                    : (at.percent >= 40 ? Colors.orange : Colors.red),
                child: Text('${at.percent}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              title: Text(_fmtDate(at.timestamp)),
              subtitle: Text('Acertos: ${at.correct}/${at.total}'),
              trailing: at.durationSeconds != null
                  ? Text('${at.durationSeconds}s')
                  : null,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Detalhes - ${_fmtDate(at.timestamp)}'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: at.details == null
                          ? Text(
                              'Acertos: ${at.correct} / ${at.total}\nPercentual: ${at.percent}%')
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: at.details!.length,
                              itemBuilder: (c, i) {
                                final d = at.details![i];
                                final ok = (d['selected'] ?? '') ==
                                    (d['correct'] ?? '');
                                return ListTile(
                                  dense: true,
                                  title: Text(d['pt'] ?? ''),
                                  subtitle: Text(
                                      'Resposta: ${d['selected'] ?? ''} • Correto: ${d['correct'] ?? ''}'),
                                  trailing: Icon(
                                      ok ? Icons.check_circle : Icons.cancel,
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
                  ),
                );
              },
            );
          }).toList(),
          const SizedBox(height: 18),
          Row(
            children: [
              ElevatedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Atualizar')),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                  onPressed: _clearHistory,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Limpar histórico')),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
