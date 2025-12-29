import '../entities/usuarios.dart';
import '../repositories/usuarios_repository.dart';

/// Caso de uso para autenticar a un usuario.
/// 
/// Verifica las credenciales proporcionadas contra el repositorio de datos.
class LoginUsuario {
  final UsuariosRepository repository;
  LoginUsuario(this.repository);

  /// Ejecuta el intento de inicio de sesion.
  /// 
  /// [email] : Correo electronico del usuario
  /// [contrasena] : Contraseña ya encriptada
  /// retorna: La entidad [Usuarios] si las credenciales son validas, o null si falla.
  Future<Usuarios?> call(String email, String contrasena){
    return repository.login(email, contrasena);
  }
}