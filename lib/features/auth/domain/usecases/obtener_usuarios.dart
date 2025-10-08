import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

/// Caso de uso para obtener todos los usuarios registrados.
/// Retorna una lista de objetos `Usuarios`.
class ObtenerUsuarios {
  final UsuariosRepository repository;

  ObtenerUsuarios(this.repository);

  Future<List<Usuarios>> call() async {
    return await repository.obtenerTodos();
  }
}