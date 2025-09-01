import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

class RegistrarUsuario {
  final UsuariosRepository repository;
  RegistrarUsuario(this.repository);

  Future<int> call(Usuarios usuarios){
    return repository.registrarUsuario(usuarios);
  }
}