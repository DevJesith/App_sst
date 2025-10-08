import '../../domain/entities/usuarios.dart';
import '../../domain/repositories/usuarios_repository.dart';
import '../models/usuario_model.dart';
import '../../../../data/database/app_database.dart';

// Implementación concreta del repositorio de usuarios.
/// Usa `AppDatabase` como fuente de datos local (SQLite).
class UsuarioRepositoryImpl implements UsuariosRepository {
  final AppDatabase db;

  UsuarioRepositoryImpl(this.db);

  /// Registra un nuevo usuario en la base de datos
  @override
  Future<int> registrarUsuario(Usuarios usuarios) async {
    return await db.insertarUsuario(
      usuarios.nombre,
      usuarios.email,
      usuarios.contrasena,
    );
  }

  /// Autentica al usuario con email y contraseña
  @override
  Future<Usuarios?> login(String email, String contrasena) async {
    final res = await db.login(email, contrasena);
    return res != null ? UsuarioModel.fromMap(res) : null;
  }

  /// Marca al usuario como verificado
  @override
  Future<bool> verificarUsuario(String email) async {
    return await db.verificarCodigo(email);
  }

  /// Verifica si el usuario ya está marcado como verificado

  @override
  Future<bool> estaVerificado(String email) async {
    return await db.estaVerificado(email);
  }

  /// Actualiza los datos del usuario en la base de datos
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

  /// Obtiene todos los usuarios registrados
  @override
  Future<List<Usuarios>> obtenerTodos() async {
    final dbInstance = await db.database;
    final res = await dbInstance.query('usuarios');
    return res.map((e) => UsuarioModel.fromMap(e)).toList();
  }

  /// Valida si el código de recuperación es correcto para el email dado
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
