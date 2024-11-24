import 'package:docfiy/db/database_base.dart';
import 'package:docfiy/db/models/statistic.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDatabase implements DatabaseService {
  static final SqliteDatabase instance = SqliteDatabase._instance();
  static Database? _database;

  SqliteDatabase._instance();
  SqliteDatabase();

  Future<Database> get db async {
    _database ??= await init();
    return _database!;
  }

  Future<Database> init() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, "stats.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async => {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS statistics (
          id INTEGER PRIMARY KEY,
          file_size INTEGER NOT NULL,
          start_at DATE NOT NULL,
          end_at DATE NOT NULL
        )''')
      },
    );
  }

  @override
  Future<int?> insert(Statistic data) async {
    Database db = await instance.db;
    return await db.insert("statistics", data.toMap());
  }

  @override
  Future<void> delete(int id) async {
    Database db = await instance.db;
    db.delete("statistics", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<Statistic>?> selectAll() async {
    Database db = await instance.db;
    final result = await db.query("statistics");

    return result.map((map) => Statistic.fromMap(map)).toList();
  }

  @override
  Future<Statistic> selectById(int id) async {
    Database db = await instance.db;
    final result = await db.query("statistics");

    return result.map((map) => Statistic.fromMap(map)).first;
  }
}
