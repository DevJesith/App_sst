import 'package:app_sst/features/auth/domain/entities/usuarios.dart';

import '../repositories/usuarios_repository.dart';

/// Caso de uso para actualizar los datos de un usuario.
/// Llama al método `actualizarUsuario` del repositorio.
class ActualizarUsuario {
  final UsuariosRepository repository;
  ActualizarUsuario(this.repository);

  Future<void> call(Usuarios usuario) async{
    await repository.actualizarUsuario(usuario);
  }

}