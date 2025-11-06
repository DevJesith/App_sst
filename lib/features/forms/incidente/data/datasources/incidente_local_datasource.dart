import 'package:app_sst/data/database/app_database.dart';
import 'package:app_sst/features/forms/incidente/data/model/incidente_model.dart';
import 'package:sqflite/sql.dart';

abstract class IncidenteLocalDatasource {
  Future<List<IncidenteModel>> getIncidentes();
  Future<IncidenteModel?> getIncidenteById(int id);
  Future<List<IncidenteModel>> getIncidenteByUsuario(int usuarioId);
  Future<int> crearIncidente(IncidenteModel incidente);
  Future<int> actualizarIncidente(IncidenteModel incidente);
  Future<int> eliminarIncidente(int id);
}

class IncidenteLocalDatasourceImpl implements IncidenteLocalDatasource {
  final AppDatabase database;

  IncidenteLocalDatasourceImpl({required this.database});

  @override
  Future<List<IncidenteModel>> getIncidentes() async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Incidente',
      orderBy: 'fecha_registro DESC',
    );
    return List.generate(maps.length, (i) {
      return IncidenteModel.fromMap(maps[i]);
    });
  }

  @override
  Future<IncidenteModel?> getIncidenteById(int id) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Incidente',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return IncidenteModel.fromMap(maps.first);
  }

  @override
  Future<List<IncidenteModel>> getIncidenteByUsuario(int usuarioId) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Incidente',
      where: 'Usuarios_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha_registro DESC',
    );

    return List.generate(maps.length, (i) {
      return IncidenteModel.fromMap(maps[i]);
    });
  }

  @override
  Future<int> crearIncidente(IncidenteModel incidente) async {
    final db = await database.database;
    return await db.insert(
      'Incidente',
      incidente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> actualizarIncidente(IncidenteModel incidente) async {
    final db = await database.database;
    return await db.update(
      'Incidente',
      incidente.toMap(),
      where: 'id = ?',
      whereArgs: [incidente.id],
    );
  }

  @override
  Future<int> eliminarIncidente(int id) async {
    final db = await database.database;
    return await db.delete('Incidente', where: 'id = ?', whereArgs: [id]);
  }
}
