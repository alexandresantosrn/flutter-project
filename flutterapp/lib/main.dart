import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutterapp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
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
  // 0 = Configurações (padrão)
  int _currentIndex = 0;

  static const List<String> _titles = [
    'Configurações',
    'Ação',
    'Estatísticas',
    'Histórico',
  ];

  static const List<Widget> _pages = [
    Center(
        child: Text('Configurações',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600))),
    Center(
        child: Text('Ação',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600))),
    Center(
        child: Text('Estatísticas',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600))),
    Center(
        child: Text('Histórico',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600))),
  ];

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
      ),
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
