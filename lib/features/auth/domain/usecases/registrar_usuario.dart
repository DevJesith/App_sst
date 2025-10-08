import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

/// Caso de uso para registrar un nuevo usuario.
/// Retorna el ID del usuario insertado.
class RegistrarUsuario {
  final UsuariosRepository repository;
  RegistrarUsuario(this.repository);

  Future<int> call(Usuarios usuarios){
    return repository.registrarUsuario(usuarios);
  }
}