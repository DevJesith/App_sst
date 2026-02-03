/// Entidad de dominio que representa un reporte.
class Incidente {
  final int? id;
  final String eventualidad;
  final int proyectoId;
  final String descripcion;
  final int diasIncapacidad;
  final String avances;
  final String estado;
  final DateTime fechaRegistro;
  final DateTime fechaCreacion;
  final int sincronizado;
  final int usuarioId;
  
  const Incidente({
    this.id,
    required this.eventualidad,
    required this.proyectoId,
    required this.descripcion,
    required this.diasIncapacidad,
    required this.avances,
    required this.estado,
    required this.fechaRegistro,
    required this.fechaCreacion,
    this.sincronizado = 0,
    required this.usuarioId
  });
}