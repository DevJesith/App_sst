import 'package:app_sst/data/database/app_database.dart';
import 'package:app_sst/features/forms/enfermedad/data/model/enfermedad_model.dart';
import 'package:sqflite/sql.dart';

abstract class EnfermedadLocalDatasource {
  Future<List<EnfermedadModel>> getEnfermedad();
  Future<EnfermedadModel?> getEnfermedadById(int id);
  Future<List<EnfermedadModel>> getEnfermedadByUsuario(int usuarioId);
  Future<int> crearEnfermedad(EnfermedadModel enfermedad);
  Future<int> actualizarEnfermedad(EnfermedadModel enfermedad);
  Future<int> eliminarEnfermedad(int id);
}

class EnfermedadLocalDataSourceImpl implements EnfermedadLocalDatasource {
  final AppDatabase database;

  EnfermedadLocalDataSourceImpl({required this.database});

  @override
  Future<List<EnfermedadModel>> getEnfermedad() async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Enfermedad_laboral',
      orderBy: 'Fecha_registro DESC',
    );
    return List.generate(maps.length, (i) {
      return EnfermedadModel.fromMap(maps[i]);
    });
  }

  @override
  Future<EnfermedadModel?> getEnfermedadById(int id) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Enfermedad_laboral',
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
      'Enfermedad_laboral',
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
      'Enfermedad_laboral',
      enfermedad.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> actualizarEnfermedad(EnfermedadModel enfermedad) async {
    final db = await database.database;
    return await db.update(
      'Enfermedad_laboral',
      enfermedad.toMap(),
      where: 'id = ?',
      whereArgs: [enfermedad.id],
    );
  }

  @override
  Future<int> eliminarEnfermedad(int id) async {
    final db = await database.database;
    return await db.delete('Enfermedad_laboral', where: 'id = ?', whereArgs: [id]);
  }
}
