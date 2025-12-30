
/// Entidad de dominio que representa un reporte
/// 
/// Contiene la informacion detallada del caso, vinculando tres niveles de jerarquia:
/// Proyecto -> Contratista -> Trabajador.
class Enfermedad {
  final int? id;
  final String eventualidad;
  final int proyectoId;
  final int contratistaId;
  final int trabajadorId;
  final String mes;
  final String descripcion;
  final int diasIncapacidad;
  final String avances;
  final String estado;
  final DateTime fechaRegistro;
  final int sincronizado;
  final int usuarioId;

  const Enfermedad({
    this.id,
    required this.eventualidad,
    required this.proyectoId,
    required this.contratistaId,
    required this.trabajadorId,
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