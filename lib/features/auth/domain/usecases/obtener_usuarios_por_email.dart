import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

/// Caso de uso para buscar un usuario especifico mediante su correo.
/// 
/// Se utiliza principalmente para validaciones o recuperar contraseña
class ObtenerUsuarioPorEmail {
  final UsuariosRepository repository;

  ObtenerUsuarioPorEmail(this.repository);

  /// Busca y retorna un [Usuarios] si existe el [email], o null si no
  Future<Usuarios?> call(String email) async {
    return await repository.obtenerPorEmail(email);
  }
}