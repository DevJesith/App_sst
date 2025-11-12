// features/auth/domain/usecases/existe_usuario.dart
import '../repositories/usuarios_repository.dart';

class EliminarUsuario {
  final UsuariosRepository repository;

  EliminarUsuario(this.repository);

  Future<void> call(int id) async {
    await repository.eliminarUsuario(id);
  }
}