import 'package:docfiy/db/models/statistic.dart';

abstract class DatabaseService {
  Future<void> init();
  Future<void> insert(Statistic statistic);
  Future<void> delete(Statistic statistic);
  Future<List<Statistic>> selectAll();
  Future<Statistic> selectById(int id);
}
