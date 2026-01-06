import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/forms/enfermedad/data/model/enfermedad_model.dart';
import 'package:sqflite/sql.dart';

/// Interfaz para el acceso a datos locales de Enfermedad Laboral.
/// Define las operaciones CRUD y las consultas a tablas maestras en cascada.
abstract class EnfermedadLocalDatasource {
  Future<List<EnfermedadModel>> getEnfermedad();
  Future<EnfermedadModel?> getEnfermedadById(int id);
  Future<List<EnfermedadModel>> getEnfermedadByUsuario(int usuarioId);
  Future<int> crearEnfermedad(EnfermedadModel enfermedad);
  Future<int> actualizarEnfermedad(EnfermedadModel enfermedad);
  Future<int> eliminarEnfermedad(int id);

  // Metodos para listas desplegables
  Future<List<Map<String, dynamic>>> getProyectos();
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectoId);
  Future<List<Map<String, dynamic>>> getTrabajadoresPorContratista(int proyectoId, int contratistaId);
}

/// Implementancion concreta del DataSource local usando SQLite.
class EnfermedadLocalDataSourceImpl implements EnfermedadLocalDatasource {
  final AppDatabase database;

  EnfermedadLocalDataSourceImpl({required this.database});

  @override
  Future<List<EnfermedadModel>> getEnfermedad() async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Enfermedad_Laboral',
      orderBy: 'fecha_registro DESC',
    );
    return List.generate(maps.length, (i) {
      return EnfermedadModel.fromMap(maps[i]);
    });
  }

  @override
  Future<EnfermedadModel?> getEnfermedadById(int id) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Enfermedad_Laboral',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return EnfermedadModel.fromMap(maps.first);
  }

  @override
  Future<List<EnfermedadModel>> getEnfermedadByUsuario(int usuarioId) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Enfermedad_Laboral',
      where: 'Usuarios_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha_registro DESC',
    );

    return List.generate(maps.length, (i) {
      return EnfermedadModel.fromMap(maps[i]);
    });
  }

  @override
  Future<int> crearEnfermedad(EnfermedadModel enfermedad) async {
    final db = await database.database;
    return await db.insert(
      'Enfermedad_Laboral',
      enfermedad.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> actualizarEnfermedad(EnfermedadModel enfermedad) async {
    final db = await database.database;
    return await db.update(
      'Enfermedad_Laboral',
      enfermedad.toMap(),
      where: 'id = ?',
      whereArgs: [enfermedad.id],
    );
  }

  @override
  Future<int> eliminarEnfermedad(int id) async {
    final db = await database.database;
    return await db.delete('Enfermedad_Laboral', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Map<String, dynamic>>> getProyectos() async {
    final db = await database.database;
    return await db.query('Proyecto');
  }

  @override
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectoId) async {
    final db = await database.database;
    // JOIN para filtrar contratistas asociados al proyecto seleccionado
    return await db.rawQuery('''
    SELECT c.id, c.Nombre
    FROM Contratista c
    INNER JOIN Contratis_Proyecto cp ON c.id = cp.Contratista_id
    WHERE cp.Proyecto_id = ?
    ''', [proyectoId]);
  }

  @override
  Future<List<Map<String, dynamic>>> getTrabajadoresPorContratista(int proyectoId, int contratistaId) async {
    final db = await database.database;
    // JOIN para filtrar trabajadores asociados al proyecto seleccionado
    return await db.rawQuery('''
    SELECT t.id, t.Nombres
    FROM Trabajador t
    INNER JOIN Trabajador_Contratis tc ON t.id = tc.Trabajador_id
    WHERE tc.Proyecto_id = ? AND tc.Contratista_id = ?
    ''', [proyectoId, contratistaId]);
    
  }
  
}
