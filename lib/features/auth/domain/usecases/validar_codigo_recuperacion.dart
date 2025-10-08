import '../repositories/usuarios_repository.dart';

/// Caso de uso para validar el código de recuperación de cuenta.
/// Retorna `true` si el código es válido para el email dado.
class ValidarCodigoRecuperacion {
  
  final UsuariosRepository repository;

  ValidarCodigoRecuperacion(this.repository);

  Future<bool> call(String email, String codigo) async {
    return await repository.validarCodigoRecuperacion(email, codigo);
  }
}