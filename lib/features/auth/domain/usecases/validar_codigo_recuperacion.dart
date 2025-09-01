import '../repositories/usuarios_repository.dart';

class ValidarCodigoRecuperacion {
  
  final UsuariosRepository repository;

  ValidarCodigoRecuperacion(this.repository);

  Future<bool> call(String email, String codigo) async {
    return await repository.validarCodigoRecuperacion(email, codigo);
  }
}