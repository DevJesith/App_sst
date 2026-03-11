import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/pqrs/data/models/pqrs_model.dart';


/// Definición del DataSource local para la entidad Pqrs
abstract class PqrsLocalDatasource {
  Future<List<PqrsModel>> getPqrs();
  Future<void> insertPqrs(PqrsModel pqrs);
  Future<void> resolverPqrs(int id);
}

/// Implementacion concreta del DataSource local usando SQLite
class PqrsLocalDataSourceImpl implements PqrsLocalDatasource {
  final AppDatabase database;

  PqrsLocalDataSourceImpl({required this.database});

  @override
  Future<void> insertPqrs(PqrsModel pqrs) async {
    final db = await database.database;
    await db.insert('Pqrs', pqrs.toMap());
  }

  @override
  Future<List<PqrsModel>> getPqrs() async {
    final db = await await database.database;
    final res = await db.query('Pqrs', orderBy: 'fecha_creacion DESC');
    return res.map((e) => PqrsModel.fromMap(e)).toList();
  }

  @override
  Future<void> resolverPqrs(int id) async {
    final db = await database.database;
    await db.update(
      'Pqrs',
      {'estado': 'Resuelto'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
