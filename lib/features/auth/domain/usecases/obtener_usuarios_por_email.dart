// features/auth/domain/usecases/obtener_usuario_por_email.dart

import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

class ObtenerUsuarioPorEmail {
  final UsuariosRepository repository;

  ObtenerUsuarioPorEmail(this.repository);

  Future<Usuarios?> call(String email) async {
    return await repository.obtenerPorEmail(email);
  }
}