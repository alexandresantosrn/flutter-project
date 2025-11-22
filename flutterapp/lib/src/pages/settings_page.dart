import 'package:flutter/cupertino.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _darkMode = false;
  String _selectedTime = '12:00'; // inicial agora em 12:00
  int _lessonSize = 5;

  // Gera horários de 00:00 até 23:30, passo de 30 minutos (48 itens)
  final List<String> _times = List.generate(48, (i) {
    final hours = (i ~/ 2).toString().padLeft(2, '0');
    final minutes = (i % 2 == 0) ? '00' : '30';
    return '$hours:$minutes';
  });

  Future<void> _showTimePicker() async {
    if (!_notifications) return;

    final initialIndex = _times.indexOf(_selectedTime);
    final defaultIndex = 24;

    final int? result = await showCupertinoModalPopup<int>(
      context: context,
      builder: (_) {
        int tempIndex = initialIndex >= 0 ? initialIndex : defaultIndex;
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text('Cancelar'),
                        onPressed: () => Navigator.of(context).pop<int>(null),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text('OK'),
                        onPressed: () =>
                            Navigator.of(context).pop<int>(tempIndex),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.separator.resolveFrom(context),
                ),
                Expanded(
                  child: CupertinoPicker(
                    backgroundColor:
                        CupertinoColors.systemBackground.resolveFrom(context),
                    scrollController:
                        FixedExtentScrollController(initialItem: tempIndex),
                    itemExtent: 36,
                    onSelectedItemChanged: (i) => tempIndex = i,
                    children: _times
                        .map((t) => Center(
                              child: Text(
                                t,
                                style: TextStyle(
                                  color: CupertinoColors.label
                                      .resolveFrom(context),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedTime = _times[result];
      });
    }
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Configurações',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        _buildSwitchTile(
          label: 'Notificações',
          value: _notifications,
          onChanged: (v) => setState(() => _notifications = v),
        ),
        const SizedBox(height: 12),
        // Usa botão Cupertino para abrir o picker (mais consistente em listas)
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _notifications ? _showTimePicker : null,
          child: Opacity(
            opacity: _notifications ? 1.0 : 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Horário de notificação',
                    style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text(_selectedTime, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    const Icon(CupertinoIcons.chevron_up_chevron_down,
                        size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 32,
          alignment: Alignment.center,
          child: Container(
            height: 1,
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Modo escuro', style: TextStyle(fontSize: 16)),
            CupertinoSwitch(
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v)),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Tamanho da lição diária', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        CupertinoSegmentedControl<int>(
          children: const {
            5: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('5')),
            10: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('10')),
            15: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('15')),
          },
          groupValue: _lessonSize,
          onValueChanged: (v) {
            setState(() => _lessonSize = v);
          },
        ),
        const SizedBox(height: 24),
        CupertinoButton.filled(
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                title: const Text('Salvar'),
                content: Text(
                  'Notificações: ${_notifications ? 'Ativas' : 'Desativadas'}\n'
                  'Horário: $_selectedTime\n'
                  'Lição diária: $_lessonSize palavras',
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            );
          },
          child: const Text('Salvar Configurações'),
        ),
      ],
    );
  }
}
