import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<void> initDb() async {
    if (_db != null) return;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'vocab.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute(
          'CREATE TABLE words(id INTEGER PRIMARY KEY, pt TEXT, en TEXT)');
    });
    // seed se vazio
    final count = Sqflite.firstIntValue(
            await _db!.rawQuery('SELECT COUNT(*) FROM words')) ??
        0;
    if (count == 0) {
      final samples = [
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
      final batch = _db!.batch();
      for (final s in samples) batch.insert('words', s);
      await batch.commit(noResult: true);
    }
  }

  static Future<List<Map<String, String>>> getRandomWords(int limit) async {
    if (_db == null) await initDb();
    final rows = await _db!
        .rawQuery('SELECT pt,en FROM words ORDER BY RANDOM() LIMIT ?', [limit]);
    return rows
        .map((r) => {'pt': r['pt'] as String, 'en': r['en'] as String})
        .toList();
  }

  static Future<int> totalCount() async {
    if (_db == null) await initDb();
    return Sqflite.firstIntValue(
            await _db!.rawQuery('SELECT COUNT(*) FROM words')) ??
        0;
  }
}
