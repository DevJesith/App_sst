
/// Entidad de dominio que representa un registro
/// 
/// Contiene la informacion sobre las sesiones de formacion compartidas,
/// vinculando el Proyecto y el Contratista mediantes sus IDs
class Capacitacion {
  final int? id;
  final int idProyecto;
  final int idContratista;
  final String descripcion;
  final int numeroCapacita;
  final int numeroPersonas;
  final String responsable;
  final DateTime fechaRegistro;
  final int sincronizado;
  final int usuarioId;

  const Capacitacion({
    this.id,
    required this.idProyecto,
    required this.idContratista,
    required this.descripcion,
    required this.numeroCapacita,
    required this.numeroPersonas,
    required this.responsable,
    required this.fechaRegistro,
    this.sincronizado = 0,
    required this.usuarioId,
  });
}