import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/forms/gestion/data/model/gestion_model.dart';
import 'package:sqflite/sql.dart';

/// Interfaz para el acceso a datos locales
/// Define las operaciones CRUD y la consulta de proyectos
abstract class GestionLocalDatasources {
  Future<List<GestionModel>> getGestion();
  Future<GestionModel?> getGestionById(int id);
  Future<List<GestionModel>> getGestionesByUsuario(int usuarioId);
  Future<int> crearGestion(GestionModel gestion);
  Future<int> actualizarGestion(GestionModel gestion);
  Future<int> eliminarGestion(int id);
  
  // Metodos para listas desplegables
  Future<List<Map<String, dynamic>>> getProyectos();
}

/// Implementacion concreta del DataSource local usando SQLite.
class GestionLocalDataSourceImpl implements GestionLocalDatasources {
  final AppDatabase database;

  GestionLocalDataSourceImpl({required this.database});

  @override
  Future<List<GestionModel>> getGestion() async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Gestion_inspeccion',
      orderBy: 'fecha_registro DESC',
    );

    return List.generate(maps.length, (i) {
      return GestionModel.fromMap(maps[i]);
    });
  }

  @override
  Future<GestionModel?> getGestionById(int id) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Gestion_inspeccion',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return GestionModel.fromMap(maps.first);
  }

  @override
  Future<List<GestionModel>> getGestionesByUsuario(int usuarioId) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Gestion_inspeccion',
      where: 'Usuarios_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha_registro DESC',
    );

    return List.generate(maps.length, (i) {
      return GestionModel.fromMap(maps[i]);
    });
  }

  @override
  Future<int> crearGestion(GestionModel gestion) async {
    final db = await database.database;
    return await db.insert(
      'Gestion_inspeccion',
      gestion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> actualizarGestion(GestionModel gestion) async {
    final db = await database.database;
    return await db.update(
      'Gestion_inspeccion',
      gestion.toMap(),
      where: 'id = ?',
      whereArgs: [gestion.id],
    );
  }

  @override
  Future<int> eliminarGestion(int id) async {
    final db = await database.database;
    return await db.delete(
      'Gestion_inspeccion',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getProyectos() async {
    final db = await database.database;
    return await db.query('Proyecto');
  }
}
