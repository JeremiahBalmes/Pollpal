import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'survey_responses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE responses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT,
            answer TEXT,
            isSynced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> saveResponse(String question, String answer) async {
    final db = await database;
    await db.insert(
      'responses',
      {'question': question, 'answer': answer, 'isSynced': 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedResponses() async {
    final db = await database;
    return await db.query('responses', where: 'isSynced = 0');
  }

  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      'responses',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
