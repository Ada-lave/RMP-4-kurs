import 'package:docfiy/db/database_base.dart';
import 'package:docfiy/db/models/statistic.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDatabase implements DatabaseService {
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    init();
    return _db!;
  }

  @override
  Future<void> init() async {
    if (_db != null) {
      return;
    }

    try {
      final String dbPath = await getDatabasesPath();
      print(dbPath);
      final String path = join(dbPath, "stats.db");
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async => {
          await db.execute('''
          CREATE TABLE statistics (
            id INTEGER PRIMARY KEY NOT NULL,
            file_size INTEGER NOT NULL,
            start_at DATE NOT NULL,
            end_at DATE NOT NULL
          )''')
        },
      );
    } catch (ex) {
      print(ex);
    }
  }

  @override
  Future<void> insert(Statistic data) async {
    final String dbPath = await getDatabasesPath();
    print(dbPath);
    await _db?.insert("statistics", data.toMap());
  }

  @override
  Future<void> delete(Statistic data) async {}

  @override
  Future<List<Statistic>> selectAll() async {
    return List.empty();
  }

  @override
  Future<Statistic> selectById(int id) async {
    return Statistic(id, 1222, DateTime.now(), DateTime.now());
  }
}
