import '../entities/usuarios.dart';

/// Contrato que define las operaciones disponibles para la gestion de usuarios
/// 
/// Esta clase pertenece a la capa de dominio. Su proposito es descoplar la logica
/// de negocio de la implemnetacion tecnica (BD).
/// La capa de datos es la encargada de implementar estos metodos
abstract class UsuariosRepository {

  /// Registra un nuevo usuario en el sistema
  /// 
  /// [usuarios]: La entidad con los datos a guardar
  /// retorna: El ID unico asignado al nuevo usuario
  Future<int> registrarUsuario(Usuarios usuarios);

  /// Autentica a un usuario verificando sus credenciales
  Future<Usuarios?> login(String email, String contrasena);

  /// Actualiza la informacion de un usuario existente.
  Future<void> actualizarUsuario(Usuarios usuario);

  /// Busca un usuario especifico por su email
  Future<Usuarios?> obtenerPorEmail(String email);

  // Obtiene el listado completo de todos los usuarios registrados.
  Future<List<Usuarios>> obtenerTodos();

  // Elimina un usuario del sistema permanentemente
  Future<void> eliminarUsuario(int id);
}