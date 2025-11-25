import 'package:flutter/material.dart';

typedef OptionTap = void Function(int index);

class QuizQuestionWidget extends StatelessWidget {
  final String portuguese;
  final List<String> options;
  final String correctAnswer;
  final bool answered;
  final int? selectedIndex;
  final OptionTap onTap;

  const QuizQuestionWidget({
    super.key,
    required this.portuguese,
    required this.options,
    required this.correctAnswer,
    required this.answered,
    required this.selectedIndex,
    required this.onTap,
  });

  Color? _optionColor(int idx) {
    final option = options[idx];
    if (!answered) return null;
    if (option == correctAnswer) return Colors.green.shade600;
    if (selectedIndex == idx && option != correctAnswer)
      return Colors.red.shade600;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Pergunta', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Center(
              child: Text(
                portuguese.toUpperCase(),
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final color = _optionColor(i);
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      color ?? Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => onTap(i),
                child: Text(options[i], style: const TextStyle(fontSize: 18)),
              );
            },
          ),
        ),
      ],
    );
  }
}
