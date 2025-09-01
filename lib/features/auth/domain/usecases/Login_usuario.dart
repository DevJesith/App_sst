import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

class LoginUsuario {
  final UsuariosRepository repository;
  LoginUsuario(this.repository);

  Future<Usuarios?> call(String email, String contrasena){
    return repository.login(email, contrasena);
  }
}