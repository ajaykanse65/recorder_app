import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recording_model.dart';

class DBService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'recordings.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recordings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            filePath TEXT,
            timestamp TEXT,
            duration INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertRecording(Recording recording) async {
    final db = await database;
    await db.insert('recordings', recording.toMap());
  }

  Future<List<Recording>> getAllRecordings() async {
    final db = await database;
    final maps = await db.query('recordings', orderBy: 'timestamp DESC');
    return maps.map((e) => Recording.fromMap(e)).toList();
  }

  Future<void> deleteRecording(int id) async {
    final db = await database;
    await db.delete(
      'recordings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
