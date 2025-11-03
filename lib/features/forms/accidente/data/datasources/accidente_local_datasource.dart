import 'package:sqflite/sqflite.dart';
import 'package:app_sst/data/database/app_database.dart';
import 'package:app_sst/features/forms/accidente/data/model/accidente_model.dart';

abstract class AccidenteLocalDatasource {
  Future<List<AccidenteModel>> getAccidentes();
  Future<AccidenteModel?> getAccidenteById(int id);
  Future<List<AccidenteModel>> getAccidenteByUsuario(int usuarioId);
  Future<int> crearAccidente(AccidenteModel accidente);
  Future<int> actualizarAccidente(AccidenteModel accidente);
  Future<int> eliminarAccidente(int id);
}

class AccidenteLocalDataSourceImpl implements AccidenteLocalDatasource {
  final AppDatabase database;

  AccidenteLocalDataSourceImpl({required this.database});

  @override
  Future<List<AccidenteModel>> getAccidentes() async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Accidente',
      orderBy: 'fecha_registro DESC',
    );
    return List.generate(maps.length, (i) {
      return AccidenteModel.fromMap(maps[i]);
    });
  }

  @override
  Future<AccidenteModel?> getAccidenteById(int id) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Accidente',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return AccidenteModel.fromMap(maps.first);
  }

  @override
  Future<List<AccidenteModel>> getAccidenteByUsuario(int usuarioId) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Accidente',
      where: 'Usuarios_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha_registro DESC',
    );

    return List.generate(maps.length, (i) {
      return AccidenteModel.fromMap(maps[i]);
    });
  }

  @override
  Future<int> crearAccidente(AccidenteModel accidente) async {
    final db = await database.database;
    return await db.insert(
      'Accidente',
      accidente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> actualizarAccidente(AccidenteModel accidente) async {
    final db = await database.database;
    return await db.update(
      'Accidente',
      accidente.toMap(),
      where: 'id = ?',
      whereArgs: [accidente.id],
    );
  }

  @override
  Future<int> eliminarAccidente(int id) async {
    
    final db = await database.database;
    return await db.delete(
      'Accidente',
      where: 'id = ?',
      whereArgs: [id],
    );
    
  }
}
