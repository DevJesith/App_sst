class Incidente {
  final int? id;
  final String eventualidad;
  final String proyecto;
  final String contratista;
  final String mes;
  final String descripcion;
  final int diasIncapacidad;
  final String avances;
  final String estado;
  final DateTime fechaRegistro;
  final int sincronizado;
  final int usuarioId;
  
  const Incidente({
    this.id,
    required this.eventualidad,
    required this.proyecto,
    required this.contratista,
    required this.mes,
    required this.descripcion,
    required this.diasIncapacidad,
    required this.avances,
    required this.estado,
    required this.fechaRegistro,
    this.sincronizado = 0,
    required this.usuarioId
  });
}