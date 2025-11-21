import 'package:flutter/cupertino.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  final List<double> _values = const [0.4, 0.8, 0.6, 0.3, 0.9];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Center(
            child: Text('Estatísticas',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600))),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _values.map((v) {
              final h = (v * 140).clamp(8.0, 140.0);
              return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        width: 22,
                        height: h,
                        decoration: BoxDecoration(
                            color: CupertinoColors.activeBlue,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 6),
                    Text('${(v * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12)),
                  ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
