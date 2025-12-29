// features/auth/domain/usecases/obtener_usuarios.dart
import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

/// Caso de uso para obetner el listado completo de usuarios
/// 
/// Util para pantallas de admin o reportes generales
class ObtenerUsuarios {
  final UsuariosRepository repository;

  ObtenerUsuarios(this.repository);

  /// Retorna una lista con todos los [Usuarios] registrados en la base de datos.
  Future<List<Usuarios>> call() async {
    return await repository.obtenerTodos();
  }
}