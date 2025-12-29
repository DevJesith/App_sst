// features/auth/domain/usecases/existe_usuario.dart
import '../repositories/usuarios_repository.dart';

/// Caso de uso encargado de eliminar un usuario del sistema.
/// 
/// Reprensentra la accion para remover un registro de usuario permanente de la base de datos.
class EliminarUsuario {
  final UsuariosRepository repository;

  EliminarUsuario(this.repository);

  /// Ejecuta la eliminacion
  /// 
  /// [id]: El identificador unico del usuario a eliminar.
  Future<void> call(int id) async {
    await repository.eliminarUsuario(id);
  }
}