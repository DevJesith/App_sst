
/// Entidad de dominio que representa un reporte de PQRS
/// 
/// En este formulario se hacen las peticiones de algun usuario,
/// para solucionar algun inconeveniente que tengan.

class Pqrs {
  final int? id;
  final String tipo;
  final String nombreSolicitante;
  final String telefonoContacto;
  final String correoContacto;
  final String descripcion;
  final DateTime fechaCreacion;
  final String estado;
  

  Pqrs({
    this.id,
    required this.tipo,
    required this.nombreSolicitante,
    required this.telefonoContacto,
    required this.correoContacto,
    required this.descripcion,
    required this.fechaCreacion,
    this.estado = 'Pendiente',
  });
}
