import 'package:app_sst/features/auth/domain/entities/usuarios.dart';

/// Interfaz que define las operaciones disponibles para manejar usuarios.
/// Permite desacoplar la lógica de negocio de la fuente de datos.
abstract class UsuariosRepository {
  Future<int> registrarUsuario(Usuarios usuarios);  // Crear nuevo usuario
  Future<Usuarios?> login(String email, String contrasena); // Autenticación
  Future<bool> verificarUsuario(String email); // Marcar como verificado
  Future<bool> estaVerificado(String email); // Consultar estado de verificación
  Future<void> actualizarUsuario(Usuarios usuario); // Actualizar datos
  Future<List<Usuarios>> obtenerTodos(); // Obtener todos los registros
  Future<bool> validarCodigoRecuperacion(String email, String codigo); // Validar código de recuperación

}
