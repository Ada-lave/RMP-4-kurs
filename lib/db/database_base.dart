import 'package:docfiy/db/models/statistic.dart';

abstract class DatabaseService {
  Future<int?> insert(Statistic statistic);
  Future<void> delete(int id);
  Future<List<Statistic>?> selectAll();
  Future<Statistic> selectById(int id);
}
