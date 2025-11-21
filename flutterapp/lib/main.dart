import 'package:flutter/cupertino.dart';
import 'src/utils/logger.dart';
import 'src/pages/settings_page.dart';
import 'src/pages/action_page.dart';
import 'src/pages/statistics_page.dart';
import 'src/pages/history_page.dart';

void main() {
  logger.i('Iniciando aplicativo');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    logger.d('Construindo MyApp (CupertinoApp)');
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: HomeTabs(),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  late final CupertinoTabController _controller;

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

  @override
  void initState() {
    super.initState();
    _controller = CupertinoTabController(initialIndex: 0);
    logger.i(
        'HomeTabs inicializado na aba ${_controller.index} (${_titles[_controller.index]})');
    int _lastIndex = _controller.index;
    _controller.addListener(() {
      if (_controller.index != _lastIndex) {
        _lastIndex = _controller.index;
        logger.i(
            'Aba selecionada: ${_controller.index} (${_titles[_controller.index]})');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.v('Construindo CupertinoTabScaffold');
    return CupertinoTabScaffold(
      controller: _controller,
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Configurações',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bolt),
            label: 'Ação',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.time),
            label: 'Histórico',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        logger.d('Construindo conteúdo da aba $index (${_titles[index]})');
        return CupertinoTabView(
          builder: (context) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text(_titles[index]),
              ),
              child: SafeArea(
                child: _pages[index],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    logger.i('Descartando HomeTabs e controlador de abas');
    _controller.dispose();
    super.dispose();
  }
}
