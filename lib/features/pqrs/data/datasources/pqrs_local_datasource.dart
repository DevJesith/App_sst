import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/pqrs/data/models/pqrs_model.dart';
import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';

class PqrsLocalDatasource {
  final AppDatabase database;

  PqrsLocalDatasource({required this.database});

  Future<void> insertPqrs(PqrsModel pqrs) async {
    final db = await database.database;
    await db.insert('Pqrs', pqrs.toMap());
  }

  Future<List<PqrsModel>> getPqrs() async {
    final db = await await database.database;
    final res = await db.query('Pqrs', orderBy: 'fecha_creacion DESC');
    return res.map((e) => PqrsModel.fromMap(e)).toList();
  }

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
