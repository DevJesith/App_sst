class Notifications {
  final int? id;
  final String titulo;
  final String cuerpo;
  final DateTime fecha;
  final bool leido;


  Notifications({
    this.id,
    required this.titulo,
    required this.cuerpo,
    required this.fecha,
    this.leido = false,
  });
}
