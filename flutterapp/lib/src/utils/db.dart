import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Attempt {
  final int id;
  final DateTime timestamp;
  final int total;
  final int correct;
  final int? durationSeconds;
  final List<Map<String, dynamic>>?
      details; // opcional: lista de {pt,en,selected,correct}

  Attempt({
    required this.id,
    required this.timestamp,
    required this.total,
    required this.correct,
    this.durationSeconds,
    this.details,
  });

  int get percent => total == 0 ? 0 : ((correct / total) * 100).round();
}

class DBHelper {
  static Database? _db;

  static Future<void> initDb() async {
    if (_db != null) return;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'vocab.db');
    _db = await openDatabase(path, version: 2, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE words(
          id INTEGER PRIMARY KEY,
          pt TEXT NOT NULL,
          en TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE attempts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp INTEGER NOT NULL,
          total INTEGER NOT NULL,
          correct INTEGER NOT NULL,
          duration_seconds INTEGER,
          details TEXT
        )
      ''');
    }, onUpgrade: (db, oldV, newV) async {
      if (oldV < 2) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS attempts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp INTEGER NOT NULL,
            total INTEGER NOT NULL,
            correct INTEGER NOT NULL,
            duration_seconds INTEGER,
            details TEXT
          )
        ''');
      }
    });

    // seed palavras se vazio
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

  // grava uma tentativa no histórico
  static Future<int> insertAttempt({
    required int total,
    required int correct,
    int? durationSeconds,
    List<Map<String, dynamic>>? details,
  }) async {
    if (_db == null) await initDb();
    final row = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'total': total,
      'correct': correct,
      'duration_seconds': durationSeconds,
      'details': details == null ? null : jsonEncode(details),
    };
    return await _db!.insert('attempts', row);
  }

  // obtém histórico (mais recentes primeiro)
  static Future<List<Attempt>> getAttempts({int limit = 100}) async {
    if (_db == null) await initDb();
    final rows =
        await _db!.query('attempts', orderBy: 'timestamp DESC', limit: limit);
    return rows.map((r) {
      final detailsText = r['details'] as String?;
      List<Map<String, dynamic>>? details;
      if (detailsText != null) {
        try {
          final decoded = jsonDecode(detailsText) as List<dynamic>;
          details =
              decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } catch (_) {
          details = null;
        }
      }
      return Attempt(
        id: r['id'] as int,
        timestamp: DateTime.fromMillisecondsSinceEpoch(r['timestamp'] as int),
        total: r['total'] as int,
        correct: r['correct'] as int,
        durationSeconds: r['duration_seconds'] as int?,
        details: details,
      );
    }).toList();
  }

  static Future<void> clearAttempts() async {
    if (_db == null) await initDb();
    await _db!.delete('attempts');
  }
}
