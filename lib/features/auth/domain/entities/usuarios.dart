// features/auth/domain/entities/usuarios.dart

/// Entidad base que representa un usuario en el sistema.
class Usuarios {
  final int? id;
  final String nombre;
  final String email;
  final String contrasena;

  Usuarios({
    this.id,
    this.nombre = '',
    required this.email,
    this.contrasena = '',
  });
}