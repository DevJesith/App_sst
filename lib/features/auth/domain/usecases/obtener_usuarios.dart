import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

class ObtenerUsuarios {
  final UsuariosRepository repository;

  ObtenerUsuarios(this.repository);

  Future<List<Usuarios>> call() async {
    return await repository.obtenerTodos();
  }
}