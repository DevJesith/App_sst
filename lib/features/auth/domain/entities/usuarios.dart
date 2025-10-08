
/// Entidad base que representa un usuario en el sistema.
/// Se usa en la capa de dominio para mantener independencia de la fuente de datos.
class Usuarios {
  final int? id;
  final String nombre;
  final String email;
  final String contrasena;
  final bool verificado;

  Usuarios({
    this.id,
    this.nombre = '',
    this.email = '',
    this.contrasena = '',
    this.verificado = false,
  });
}
