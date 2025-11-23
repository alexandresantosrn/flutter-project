import 'package:flutter/material.dart';
import '../utils/prefs.dart';

class SettingsPage extends StatefulWidget {
  final ValueNotifier<bool> isDark;
  const SettingsPage({super.key, required this.isDark});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  String _selectedTime = '12:00';
  int _lessonSize = 5;

  // Gera horários de 00:00 até 23:30, passo de 30 minutos (48 itens)
  final List<String> _times = List.generate(48, (i) {
    final hours = (i ~/ 2).toString().padLeft(2, '0');
    final minutes = (i % 2 == 0) ? '00' : '30';
    return '$hours:$minutes';
  });

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = await SettingsPrefs.load();
    if (!mounted) return;
    setState(() {
      _notifications = data.notifications;
      _selectedTime = data.selectedTime;
      _lessonSize = data.lessonSize;
      // atualiza o notifier caso divergente
      if (widget.isDark.value != data.darkMode) {
        widget.isDark.value = data.darkMode;
      }
    });
  }

  Future<void> _saveSettings() async {
    final data = SettingsData(
      notifications: _notifications,
      selectedTime: _selectedTime,
      darkMode: widget.isDark.value,
      lessonSize: _lessonSize,
    );
    await SettingsPrefs.save(data);
  }

  Future<void> _pickTime() async {
    if (!_notifications) return;

    final initialIndex = _times.indexOf(_selectedTime);
    final scrollController = ScrollController(
        initialScrollOffset: (initialIndex >= 0 ? initialIndex : 24) * 56.0);

    final int? result = await showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        return SizedBox(
          height: 360,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop<int>(null),
                      child: const Text('Cancelar'),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Escolher horário',
                          style: Theme.of(ctx).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop<int>(null),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _times.length,
                  itemBuilder: (c, i) {
                    final time = _times[i];
                    final selected = time == _selectedTime;
                    return ListTile(
                      title: Center(
                        child: Text(
                          time,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected
                                ? Theme.of(ctx).colorScheme.primary
                                : null,
                            fontWeight: selected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                      selected: selected,
                      onTap: () => Navigator.of(ctx).pop<int>(i),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedTime = _times[result];
      });
      await _saveSettings();
    }
  }

  Widget _lessonSizeChips(BuildContext context) {
    final options = [5, 10, 15];
    return Row(
      children: options.map((opt) {
        final selected = _lessonSize == opt;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
                foregroundColor: selected ? Colors.white : Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: selected ? 2 : 0,
              ),
              onPressed: () async {
                setState(() => _lessonSize = opt);
                await _saveSettings();
              },
              child: Text(
                '$opt',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      }).toList(),
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

        // Notificações
        SwitchListTile(
          title: const Text('Notificações'),
          value: _notifications,
          onChanged: (v) async {
            setState(() => _notifications = v);
            await _saveSettings();
          },
        ),

        // Horário de notificação
        ListTile(
          enabled: _notifications,
          title: const Text('Horário de notificação'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_selectedTime, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more),
            ],
          ),
          onTap: _notifications ? _pickTime : null,
        ),
        const Divider(),

        // Modo noturno (atualiza notifier e salva)
        SwitchListTile(
          title: const Text('Modo noturno'),
          value: widget.isDark.value,
          onChanged: (v) async {
            widget.isDark.value = v;
            await _saveSettings();
            if (mounted) setState(() {}); // atualiza UI local se necessário
          },
        ),

        const SizedBox(height: 16),
        const Text('Tamanho da lição diária', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        _lessonSizeChips(context),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: () async {
            await _saveSettings();
            final snack =
                'Notificações: ${_notifications ? 'Ativas' : 'Desativadas'} • '
                'Horário: $_selectedTime • Lição diária: $_lessonSize palavras';
            if (mounted)
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(snack)));
          },
          child: const Text('Salvar Configurações'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
