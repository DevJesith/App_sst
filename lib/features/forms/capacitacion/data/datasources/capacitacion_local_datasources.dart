import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/forms/capacitacion/data/model/capacitacion_model.dart';
import 'package:sqflite/sqflite.dart';

/// Interfaz para el acceso a datos locales de Capacitaciones.
/// Define las operaciones CRUD y las consultas a tablas maestras.
abstract class CapacitacionLocalDataSource {
  Future<List<CapacitacionModel>> getCapacitaciones();
  Future<CapacitacionModel?> getCapacitacionById(int id);
  Future<List<CapacitacionModel>> getCapacitacionesByUsuario(int usuarioId);
  Future<int> insertCapacitacion(CapacitacionModel capacitacion);
  Future<int> updateCapacitacion(CapacitacionModel capacitacion);
  Future<int> deleteCapacitacion(int id);

  // Metodos para listas desplegables
  Future<List<Map<String, dynamic>>> getProyectos();
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectoId);
}

/// Implementacion concreta del Datasource local usando SQLite.
class CapacitacionLocalDataSourceImpl implements CapacitacionLocalDataSource {
  final AppDatabase database;

  CapacitacionLocalDataSourceImpl({required this.database});

  @override
  Future<List<CapacitacionModel>> getCapacitaciones() async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Capacitacion',
      orderBy: 'fecha_registro DESC',
    );
    
    return List.generate(maps.length, (i) {
      return CapacitacionModel.fromMap(maps[i]);
    });
  }

  @override
  Future<CapacitacionModel?> getCapacitacionById(int id) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Capacitacion',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return CapacitacionModel.fromMap(maps.first);
  }

  @override
  Future<List<CapacitacionModel>> getCapacitacionesByUsuario(int usuarioId) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Capacitacion',
      where: 'usuarios_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha_registro DESC',
    );
    
    return List.generate(maps.length, (i) {
      return CapacitacionModel.fromMap(maps[i]);
    });
  }

  @override
  Future<int> insertCapacitacion(CapacitacionModel capacitacion) async {
    final db = await database.database;
    return await db.insert(
      'Capacitacion',
      capacitacion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> updateCapacitacion(CapacitacionModel capacitacion) async {
    final db = await database.database;
    return await db.update(
      'Capacitacion',
      capacitacion.toMap(),
      where: 'id = ?',
      whereArgs: [capacitacion.id],
    );
  }

  @override
  Future<int> deleteCapacitacion(int id) async {
    final db = await database.database;
    return await db.delete(
      'Capacitacion',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getProyectos() async {
    final db = await database.database;
    return await db.query('Proyecto');
  }

  @override
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectoId) async {
    final db = await database.database;
    return await db.rawQuery('''
    SELECT c.id, c.Nombre
    FROM Contratista c
    INNER JOIN Contratis_Proyecto cp ON c.id = cp.Contratista_id
    WHERE cp.Proyecto_id = ?
    ''', [proyectoId]);
    
  }
}