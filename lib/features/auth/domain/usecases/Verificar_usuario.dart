import '../repositories/usuarios_repository.dart';

class VerificarUsuario {
  final UsuariosRepository repository;
  VerificarUsuario(this.repository);

  Future<bool> call(String email){
    return repository.verificarUsuario(email);
  }
}