import 'package:app_sst/features/auth/domain/entities/usuarios.dart';

abstract class UsuariosRepository {
  Future<int> registrarUsuario(Usuarios usuarios);
  Future<Usuarios?> login(String email, String contrasena);
  Future<bool> verificarUsuario(String email);
  Future<bool> estaVerificado(String email);
  Future<void> actualizarUsuario(Usuarios usuario);
  Future<List<Usuarios>> obtenerTodos();
  Future<bool> validarCodigoRecuperacion(String email, String codigo);
}
