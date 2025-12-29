/// Entidad base que representa un usuario en el sistema.
/// 
/// Esta clase es pura y adnostica a la infraestructura.
/// Contiene los datos esenciales necesarios para la logica ed negocio y autenticacion.
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