// features/auth/domain/repositories/usuarios_repository.dart

import '../entities/usuarios.dart';

abstract class UsuariosRepository {
  Future<int> registrarUsuario(Usuarios usuarios);
  Future<Usuarios?> login(String email, String contrasena);
  Future<void> actualizarUsuario(Usuarios usuario);
  Future<Usuarios?> obtenerPorEmail(String email); // ✅ Nuevo
  Future<List<Usuarios>> obtenerTodos();
  Future<void> eliminarUsuario(int id); // ✅ Opcional
}