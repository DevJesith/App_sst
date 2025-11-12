// features/auth/data/repositories_impl/usuario_repository_impl.dart

import '../../domain/entities/usuarios.dart';
import '../../domain/repositories/usuarios_repository.dart';
import '../models/usuario_model.dart';
import '../../../../data/database/app_database.dart';

class UsuarioRepositoryImpl implements UsuariosRepository {
  final AppDatabase db;

  UsuarioRepositoryImpl(this.db);

  @override
  Future<int> registrarUsuario(Usuarios usuarios) async {
    return await db.insertarUsuario(
      usuarios.nombre,
      usuarios.email,
      usuarios.contrasena,
    );
  }

  @override
  Future<Usuarios?> login(String email, String contrasena) async {
    final res = await db.login(email, contrasena);
    return res != null ? UsuarioModel.fromMap(res) : null;
  }

  @override
  Future<void> actualizarUsuario(Usuarios usuario) async {
    final dbInstance = await db.database;
    await dbInstance.update(
      'usuarios',
      UsuarioModel(
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        contrasena: usuario.contrasena,
      ).toMap(),
      where: 'email = ?',
      whereArgs: [usuario.email],
    );
  }

  @override
  Future<Usuarios?> obtenerPorEmail(String email) async {
    final dbInstance = await db.database;
    final res = await dbInstance.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (res.isEmpty) return null;
    return UsuarioModel.fromMap(res.first);
  }

  @override
  Future<List<Usuarios>> obtenerTodos() async {
    final dbInstance = await db.database;
    final res = await dbInstance.query('usuarios');
    return res.map((e) => UsuarioModel.fromMap(e)).toList();
  }

  @override
  Future<void> eliminarUsuario(int id) async {
    final dbInstance = await db.database;
    await dbInstance.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}