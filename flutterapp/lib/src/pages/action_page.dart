import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/db.dart';
import '../utils/quiz_ui.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({super.key});

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  final Random _rnd = Random();
  // inicializa com lista vazia para evitar LateInitializationError
  List<Map<String, String>> _questions = [];
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
    _initAndStart();
  }

  Future<void> _initAndStart() async {
    await DBHelper.initDb();
    await _loadLessonSizeAndStart();
  }

  Future<void> _loadLessonSizeAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final stored =
        prefs.getInt('lessonSize') ?? prefs.getInt('lesson_size') ?? 5;
    _lessonSize = (stored <= 0) ? 5 : stored;
    final total = await DBHelper.totalCount();
    if (_lessonSize > total) _lessonSize = total;
    final picked = await DBHelper.getRandomWords(_lessonSize);
    setState(() {
      _questions = picked;
      _currentIndex = 0;
      _correctCount = 0;
      _finished = false;
      _answered = false;
      _selectedOptionIndex = null;
    });
    _prepareOptions();
  }

  void _prepareOptions() {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;
    final current = _questions[_currentIndex];
    final correct = current['en']!;
    // pegar 3 distractors do DB (carregar 3 aleatórios diferentes)
    final others = <String>[];
    // fetch more than needed to ensure diversidade (na prática pode otimizar)
    DBHelper.getRandomWords(10).then((list) {
      for (var e in list) {
        if (e['en'] != correct && others.length < 3) others.add(e['en']!);
      }
      final opts = [correct, ...others.take(3)];
      opts.shuffle(_rnd);
      if (!mounted) return;
      setState(() {
        _currentOptions = opts;
        _answered = false;
        _selectedOptionIndex = null;
      });
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
    if (selected == correct) _correctCount++;

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_currentIndex + 1 >= _questions.length) {
        setState(() => _finished = true);
      } else {
        setState(() => _currentIndex++);
        _prepareOptions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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
                onPressed: () async {
                  await _loadLessonSizeAndStart();
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
      child: QuizQuestionWidget(
        portuguese: current['pt']!,
        options: _currentOptions,
        correctAnswer: current['en']!,
        answered: _answered,
        selectedIndex: _selectedOptionIndex,
        onTap: _onOptionTap,
      ),
    );
  }
}
