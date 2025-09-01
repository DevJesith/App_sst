import '../repositories/usuarios_repository.dart';

class EstaVerificado {
  final UsuariosRepository repository;
  EstaVerificado(this.repository);

  Future<bool> call(String email){
    return repository.estaVerificado(email);
  }
}