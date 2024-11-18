import 'package:docfiy/db/database_base.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDatabase implements DatabaseService {
  static SqliteDatabase? _db;

  @override
  Future<void> init() async {
    if (_db != null) {
      return;
    }

    try {
      final String dbPath = await getDatabasesPath();
      final String path = join(dbPath, "stats.db");
      await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async => {
          await db.execute('''CREATE TABLE statistics (
          id INTEGER PRIMARY KEY NOT NULL,
          file_size INTEGER NOT NULL,
          start_at DATE NOT NULL,
          end_at DATE NOT NULL
          )''')
        },
      );
    } 
    catch (ex) {
      print(ex);
    }
  }
}
