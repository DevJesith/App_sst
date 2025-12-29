import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

/// Caso de uso para registrar un nuevo usuario.
/// 
/// Persiste la informacion de un nuevo usuario en la base de datos
class RegistrarUsuario {
  final UsuariosRepository repository;
  RegistrarUsuario(this.repository);

  /// Ejecuta el registro del registro
  /// 
  /// [usuarios] : La entidad con los datos a guardar
  /// retorna: el ID [id] asignado al nuevo usuario creado 
  Future<int> call(Usuarios usuarios){
    return repository.registrarUsuario(usuarios);
  }
}