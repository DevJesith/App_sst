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
