import 'package:sqflite/sqflite.dart';
import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/forms/accidente/data/model/accidente_model.dart';

/// Interfaz para el acceso a datos locales de Accidentes
/// Define las operaciones CRUD y las consultas a tablas maestras
abstract class AccidenteLocalDatasource {
  Future<List<AccidenteModel>> getAccidentes();
  Future<AccidenteModel?> getAccidenteById(int id);
  Future<List<AccidenteModel>> getAccidenteByUsuario(int usuarioId);
  Future<int> crearAccidente(AccidenteModel accidente);
  Future<int> actualizarAccidente(AccidenteModel accidente);
  Future<int> eliminarAccidente(int id);

  // Metodos para listas desplegables
  Future<List<Map<String, dynamic>>> getProyectos();
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectosId);
}


/// Implementacion concreta del DataSource local usando SQLite.
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
    return await db.delete('Accidente', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Map<String, dynamic>>> getProyectos() async {
    final db = await database.database;
    return await db.query('Proyecto');
  }

  @override
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectosId) async {
    final db = await database.database;

    //Hacemos el JOIN para traer solo los contratistas de ese proyecto
    return await db.rawQuery(''' 
    SELECT c.id, c.Nombre FROM Contratista c
    INNER JOIN Contratis_Proyecto cp ON c.id = cp.Contratista_id
    WHERE cp.Proyecto_id = ?
    ''', [proyectosId]);
    
  }
}
