import '../../domain/entities/usuarios.dart';
import '../../domain/repositories/usuarios_repository.dart';
import '../models/usuario_model.dart';
import '../../../../data/database/app_database.dart';

/// Esta clase de encrga de la comunicacion directa con la base de datos SQLite
/// a traves de la instancia [AppDatabase]. Convierte los modelos de datos en entidades
/// de dominio y viceversa.
class UsuarioRepositoryImpl implements UsuariosRepository {
  final AppDatabase db;

  UsuarioRepositoryImpl(this.db);

  /// Registra un nuevo usuario a la base de datos.
  /// 
  /// Retorna el [int] que representa el ID del usuario recien creado.
  /// Lanza una [Exception] si ocurre un error en la insercion.
  @override
  Future<int> registrarUsuario(Usuarios usuarios) async {
    try {
      return await db.insertarUsuario(
        usuarios.nombre,
        usuarios.apellido,
        usuarios.email,
        usuarios.contrasena,
      );
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Verifica las credenciales de acceso
  /// 
  /// Busca un usuario que coincida con el [email] y la [contrasena].
  /// Retorna la entidad [Usuarios] si es exitoso, o 'null' si no se encuentra
  @override
  Future<Usuarios?> login(String email, String contrasena) async {
    try {
      final res = await db.login(email, contrasena);
      return res != null ? UsuarioModel.fromMap(res) : null;
    } catch (e) {
      throw Exception('Error en el incio de sesion:  $e');
    }
  }

  /// Actualiza la informacion de un usuario existente.
  /// 
  /// Utiliza el [email] como clave para encontrar el registro a modificar.
  @override
  Future<void> actualizarUsuario(Usuarios usuario) async {
    try {
      final dbInstance = await db.database;

      // Convertimos la entidad a modelo para obtener el Mapa
      final usuarioModel = UsuarioModel(
        id: usuario.id,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        email: usuario.email,
        contrasena: usuario.contrasena,
      );

      await dbInstance.update(
        'usuarios',
        usuarioModel.toMap(),
        where: 'email = ?',
        whereArgs: [usuario.email],
      );
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  /// Busca un usuario especifico por su email.
  /// 
  /// Util para validacioness
  @override
  Future<Usuarios?> obtenerPorEmail(String email) async {
    try {
      final dbInstance = await db.database;
      final res = await dbInstance.query(
        'usuarios',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (res.isEmpty) return null;
      return UsuarioModel.fromMap(res.first);
    } catch (e) {
      throw Exception('Error al buscar usuario por email: $e');
    }
  }

  /// Obtiene la lista completa de usuarios registrados en el sistema.
  @override
  Future<List<Usuarios>> obtenerTodos() async {
    try {
      final dbInstance = await db.database;
      final res = await dbInstance.query('usuarios');

      // Convertimos la lista de mapas a lista de entidades
      return res.map((e) => UsuarioModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Error al obtener la lista ed usuarios: $e');
    }
  }

  /// Elimina un usuario de la base de datos por su [id].
  @override
  Future<void> eliminarUsuario(int id) async {
    try {
      final dbInstance = await db.database;
      await dbInstance.delete('usuarios', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }
}
