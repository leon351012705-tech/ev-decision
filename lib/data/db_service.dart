import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/evaluation.dart';

/// SQLite 持久化：评估记录的增删查。
class DbService {
  static Database? _db;

  static Future<Database> _open() async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'ev_decision.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE evaluations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at TEXT NOT NULL,
            user_profile TEXT NOT NULL,
            selected_cars TEXT NOT NULL,
            report_markdown TEXT NOT NULL,
            recommended_car_id TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<int> insert(EvaluationRecord record) async {
    final db = await _open();
    return db.insert('evaluations', record.toMap());
  }

  /// 按时间倒序返回全部评估记录。
  static Future<List<EvaluationRecord>> all() async {
    final db = await _open();
    final rows = await db.query('evaluations', orderBy: 'created_at DESC');
    return rows.map(EvaluationRecord.fromMap).toList();
  }

  static Future<void> delete(int id) async {
    final db = await _open();
    await db.delete('evaluations', where: 'id = ?', whereArgs: [id]);
  }
}
