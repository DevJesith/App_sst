import '../repositories/usuarios_repository.dart';

/// Caso de uso para verificar si un usuario ya está marcado como verificado.
/// Retorna `true` si el usuario ha sido verificado en la base de datos.
class EstaVerificado {
  final UsuariosRepository repository;
  EstaVerificado(this.repository);

  Future<bool> call(String email){
    return repository.estaVerificado(email);
  }
}