import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({super.key});

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  final Random _rnd = Random();
  late List<Map<String, String>> _bank;
  late List<Map<String, String>> _questions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _lessonSize = 5;

  bool _answered = false;
  int? _selectedOptionIndex;
  List<String> _currentOptions = [];

  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _prepareBank();
    _loadLessonSizeAndStart();
  }

  void _prepareBank() {
    // Banco de palavras (pt -> en). Expanda conforme necessário.
    _bank = [
      {'pt': 'casa', 'en': 'house'},
      {'pt': 'gato', 'en': 'cat'},
      {'pt': 'cachorro', 'en': 'dog'},
      {'pt': 'livro', 'en': 'book'},
      {'pt': 'carro', 'en': 'car'},
      {'pt': 'árvore', 'en': 'tree'},
      {'pt': 'água', 'en': 'water'},
      {'pt': 'sol', 'en': 'sun'},
      {'pt': 'lua', 'en': 'moon'},
      {'pt': 'cadeira', 'en': 'chair'},
      {'pt': 'janela', 'en': 'window'},
      {'pt': 'mesa', 'en': 'table'},
      {'pt': 'rua', 'en': 'street'},
      {'pt': 'flor', 'en': 'flower'},
      {'pt': 'amigo', 'en': 'friend'},
    ];
  }

  Future<void> _loadLessonSizeAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final stored =
        prefs.getInt('lessonSize') ?? prefs.getInt('lesson_size') ?? 5;
    setState(() {
      _lessonSize = (stored <= 0) ? 5 : min(stored, _bank.length);
    });
    _startQuiz();
  }

  void _startQuiz() {
    final pool = List<Map<String, String>>.from(_bank);
    pool.shuffle(_rnd);
    _questions = pool.take(_lessonSize).toList();
    _currentIndex = 0;
    _correctCount = 0;
    _finished = false;
    _answered = false;
    _selectedOptionIndex = null;
    _prepareOptions();
  }

  void _prepareOptions() {
    final current = _questions[_currentIndex];
    final correct = current['en']!;
    // pegar 3 distractors diferentes do correto
    final others =
        _bank.where((w) => w['en'] != correct).map((e) => e['en']!).toList();
    others.shuffle(_rnd);
    final opts = [correct, ...others.take(3)];
    opts.shuffle(_rnd);
    setState(() {
      _currentOptions = opts;
      _answered = false;
      _selectedOptionIndex = null;
    });
  }

  void _onOptionTap(int idx) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOptionIndex = idx;
    });

    final current = _questions[_currentIndex];
    final correct = current['en']!;
    final selected = _currentOptions[idx];
    if (selected == correct) {
      _correctCount++;
    }

    // esperar curto período para mostrar feedback e avançar
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_currentIndex + 1 >= _questions.length) {
        setState(() {
          _finished = true;
        });
      } else {
        setState(() {
          _currentIndex++;
        });
        _prepareOptions();
      }
    });
  }

  Color? _optionColor(int idx) {
    if (!_answered) return null;
    final current = _questions[_currentIndex];
    final correct = current['en']!;
    final selected = _currentOptions[idx];
    if (selected == correct) return Colors.green.shade600;
    if (_selectedOptionIndex == idx && selected != correct)
      return Colors.red.shade600;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      final percent = (_lessonSize == 0)
          ? 0
          : ((_correctCount / _lessonSize) * 100).round();
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lição finalizada',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text('Acertos: $_correctCount / $_lessonSize',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Percentual: $percent%',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _startQuiz();
                  });
                },
                child: const Text('Recomeçar'),
              ),
            ],
          ),
        ),
      );
    }

    final current = _questions[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Pergunta ${_currentIndex + 1} / $_lessonSize',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Center(
                child: Text(
                  current['pt']!.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: _currentOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final opt = _currentOptions[i];
                final color = _optionColor(i);
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        color ?? Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  // manter onPressed definido para evitar estilo "disabled"
                  // o próprio _onOptionTap já ignora taps quando _answered == true
                  onPressed: () => _onOptionTap(i),
                  child: Text(opt, style: const TextStyle(fontSize: 18)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
