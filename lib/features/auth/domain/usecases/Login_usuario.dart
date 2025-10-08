import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

/// Caso de uso para autenticar a un usuario.
/// Retorna una instancia de `Usuarios` si las credenciales son válidas.
class LoginUsuario {
  final UsuariosRepository repository;
  LoginUsuario(this.repository);

  Future<Usuarios?> call(String email, String contrasena){
    return repository.login(email, contrasena);
  }
}