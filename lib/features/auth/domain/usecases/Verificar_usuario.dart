import '../repositories/usuarios_repository.dart';

/// Caso de uso para marcar a un usuario como verificado.
/// Retorna `true` si la operación fue exitosa.
class VerificarUsuario {
  final UsuariosRepository repository;
  VerificarUsuario(this.repository);

  Future<bool> call(String email){
    return repository.verificarUsuario(email);
  }
}