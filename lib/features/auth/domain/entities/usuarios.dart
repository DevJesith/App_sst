// features/auth/domain/entities/usuarios.dart

/// Entidad base que representa un usuario en el sistema.
class Usuarios {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String contrasena;

  Usuarios({
    this.id,
    this.nombre = '',
    this.apellido = '',
    required this.email,
    this.contrasena = '',
  });
}