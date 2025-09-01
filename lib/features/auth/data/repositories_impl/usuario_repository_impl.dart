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
  Future<bool> verificarUsuario(String email) async {
    return await db.verificarCodigo(email);
  }

  @override
  Future<bool> estaVerificado(String email) async {
    return await db.estaVerificado(email);
  }

  //Actualizar
  Future<void> actualizarUsuario(Usuarios usuario) async {
    final dbInstance = await db.database;
    await dbInstance.update(
      'usuarios',
      UsuarioModel(
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        contrasena: usuario.contrasena,
        verificado: usuario.verificado,
      ).toMap(),
      where: 'email = ?',
      whereArgs: [usuario.email],
    );
  }

  // Obetenr registros
  @override
  Future<List<Usuarios>> obtenerTodos() async {
    final dbInstance = await db.database;
    final res = await dbInstance.query('usuarios');
    return res.map((e) => UsuarioModel.fromMap(e)).toList();
  }

  @override
  Future<bool> validarCodigoRecuperacion(String email, String codigo) async {
    final dbInstance = await db.database;
    print('🔍 Validando código: $codigo para $email');
    final res = await dbInstance.query(
      'codigos_recuperacion',
      where: 'email = ? AND codigo = ?',
      whereArgs: [email, codigo],
    );
    return res.isNotEmpty;
  }
}
