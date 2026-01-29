
/// Entidad de dominio que representa un reporte de Accidente de Trabajo.
/// 
/// En este formulario se guardan los nombres del Proyecto y Contratista como texto
/// para manetener un registro historico inmutable, aunque la selecccion se haga mediante listas dinamicas

class Accidente {
  final int? id;
  final String eventualidad;
  final int proyectoId;
  final int contratistaId;
  final String descripcion;
  final int diasIncapacidad;
  final String avances;
  final String estado;
  final DateTime fechaRegistro;

  /// Indica si el registro ya fue subido a la nube (1) o esta pendiente (0)
  final int sincronizado;
  final int usuarioId;

  const Accidente({
    this.id,
    required this.eventualidad,
    required this.proyectoId,
    required this.contratistaId,
    required this.descripcion,
    required this.diasIncapacidad,
    required this.avances,
    required this.estado,
    required this.fechaRegistro,
    this.sincronizado = 0,
    required this.usuarioId,
  });
}

