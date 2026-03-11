class Pqrs {
  final int? id;
  final String tipo;
  final String nombreSolicitante;
  final String correoContacto;
  final String descripcion;
  final DateTime fechaCreacion;
  final String estado;

  Pqrs({
    this.id,
    required this.tipo,
    required this.nombreSolicitante,
    required this.correoContacto,
    required this.descripcion,
    required this.fechaCreacion,
    this.estado = 'Pendiente',
  });
}
