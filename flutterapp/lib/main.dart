import 'package:flutter/material.dart';
import 'src/utils/logger.dart';
import 'src/utils/prefs.dart';
import 'src/pages/settings_page.dart';
import 'src/pages/action_page.dart';
import 'src/pages/statistics_page.dart';
import 'src/pages/history_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  logger.i('Iniciando app');

  final settings = await SettingsPrefs.load();
  final isDark = ValueNotifier<bool>(settings.darkMode);

  runApp(MyApp(isDark: isDark));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<bool> isDark;
  const MyApp({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    logger.d('Construindo MyApp (MaterialApp)');
    return ValueListenableBuilder<bool>(
      valueListenable: isDark,
      builder: (context, dark, _) {
        return MaterialApp(
          title: 'Flutterapp',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light()
              .copyWith(useMaterial3: false, primaryColor: Colors.blue),
          darkTheme: ThemeData.dark().copyWith(useMaterial3: false),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: HomePage(isDark: isDark),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final ValueNotifier<bool> isDark;
  const HomePage({super.key, required this.isDark});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    'Configurações',
    'Ação',
    'Estatísticas',
    'Histórico',
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SettingsPage(isDark: widget.isDark),
      const ActionPage(),
      const StatisticsPage(),
      const HistoryPage(),
    ];
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    logger.i('Aba selecionada: $index (${_titles[index]})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex]), centerTitle: true),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configurações'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Ação'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Estatísticas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Histórico'),
        ],
      ),
    );
  }
}
