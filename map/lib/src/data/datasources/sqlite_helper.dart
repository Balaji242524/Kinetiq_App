import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pose_data_model.dart';
import '../../core/logger.dart';

class SQLiteHelper {
  static final SQLiteHelper _instance = SQLiteHelper._internal();
  factory SQLiteHelper() => _instance;
  SQLiteHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'poses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE poses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        keypoints_json TEXT NOT NULL, -- Stores keypoints as a JSON string [cite: 22]
        image_path TEXT NOT NULL -- Stores the local path or cloud URL [cite: 23]
      )
    ''');
  }

  Future<int> insertPose(PoseData pose) async {
    try {
      final db = await database;
      final id = await db.insert('poses', pose.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      AppLogger.log('Successfully inserted pose with id $id into SQLite.');
      return id;
    } catch (e, s) {
      AppLogger.log('DB Error: Failed to insert pose', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<List<PoseData>> getPoses() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('poses', orderBy: 'timestamp DESC');
      AppLogger.log('Fetched ${maps.length} entries from SQLite.');
      return List.generate(maps.length, (i) {
        return PoseData.fromMap(maps[i]);
      });
    } catch (e, s) {
      AppLogger.log('DB Error: Failed to fetch poses', error: e, stackTrace: s);
      return [];
    }
  }
}