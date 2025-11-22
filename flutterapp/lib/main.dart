import 'package:flutter/material.dart';
import 'src/utils/logger.dart';
import 'src/pages/settings_page.dart';
import 'src/pages/action_page.dart';
import 'src/pages/statistics_page.dart';
import 'src/pages/history_page.dart';

void main() {
  logger.i('Iniciando app');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    logger.d('Construindo MyApp (MaterialApp)');
    return MaterialApp(
      title: 'Flutterapp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false, primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  final List<Widget> _pages = const [
    SettingsPage(),
    ActionPage(),
    StatisticsPage(),
    HistoryPage(),
  ];

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
