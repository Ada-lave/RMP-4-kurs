import 'package:docfiy/db/database_base.dart';
import 'package:docfiy/db/models/statistic.dart';
import 'package:postgres/postgres.dart';

class PostgreDatabase implements DatabaseService {
  String host;
  int port;
  String password;
  String user;
  String db;

  PostgreDatabase(this.host, this.port, this.password, this.user, this.db);

  Future<void> init() async {
    final connection = await getConnection();
    final result = await connection.execute('''
          CREATE TABLE IF NOT EXISTS statistics (
          id SERIAL PRIMARY KEY,
          file_size INTEGER NOT NULL,
          start_at DATE NOT NULL,
          end_at DATE NOT NULL
        )''');
  }

  @override
  Future<void> delete(int id) async {
    final connection = await getConnection();
    final result = await connection.execute(
      r'DELETE FROM statistics WHERE id = $1',
      parameters: [id],
    );
  }

  @override
  Future<int?> insert(Statistic statistic) async {
    final connection = await getConnection();
    final result = await connection.execute(
      r'INSERT INTO statistics(file_size, start_at, end_at) VALUES($1, $2, $3)',
      parameters: [statistic.fileSize, statistic.endAt, statistic.startAt],
    );

    return result.affectedRows;
  }

  @override
  Future<List<Statistic>?> selectAll() async {
    final connection = await getConnection();
    var result = await connection.execute("SELECT * FROM statistics;");
    List<Statistic> statistics = [];

    for (var i = 0; i < result.length; i++) {
      print(result[i].toList());
      statistics.add(Statistic(
          id: result[i][0] as int,
          fileSize: result[i][1] as int,
          startAt: (result[i][2] as DateTime).toString(),
          endAt: (result[i][3] as DateTime).toString()));
    }

    print(statistics);

    return statistics;
  }

  @override
  Future<Statistic> selectById(int id) async {
    final connection = await getConnection();
    var result = await connection
        .execute(r"SELECT * FROM statistics WHERE id = $1", parameters: [id]);

    return Statistic(
      id: result[0][0] as int,
      fileSize: result[0][1] as int,
      startAt: (result[0][2] as DateTime).toString(),
      endAt: (result[0][3] as DateTime).toString(),
    );
  }

  Future<Connection> getConnection() {
    return Connection.open(
        Endpoint(
            host: host,
            database: db,
            username: user,
            password: password,
            port: port),
        settings: ConnectionSettings(sslMode: SslMode.disable));
  }
}
