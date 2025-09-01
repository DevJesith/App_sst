import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

class ActualizarUsuario {
  final UsuariosRepository repository;
  ActualizarUsuario(this.repository);

  Future<void> call(Usuarios usuario) async{
    await repository.actualizarUsuario(usuario);
  }

}