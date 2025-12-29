import '../entities/capacitacion.dart';

/// Contrato (interface) para el manejo de datos
/// 
/// Define las operaciones que la capa de datos debe implementar,
/// permitiendo a la capa de dominio ser agnostica a la BD.
abstract class CapacitacionRepository {

  /// Obtiene todas las capacitaciones registradas.
  Future<List<Capacitacion>> getCapacitaciones();

  /// Busca una capacitacion por su ID
  Future<Capacitacion?> getCapacitacionById(int id);

  /// Obtiene las capacitaciones creadas por un usuario especifico
  Future<List<Capacitacion>> getCapacitacionesByUsuario(int usuarioId);

  /// Guarda un nuevo registro
  Future<int> createCapacitacion(Capacitacion capacitacion);

  /// Actualiza una capacitacion existente
  Future<int> updateCapacitacion(Capacitacion capacitacion);

  /// Elimina una capacitacion por su ID
  Future<int> deleteCapacitacion(int id);

  /// Obtiene la lista de proyectos disponibles.
  Future<List<Map<String, dynamic>>> getProyectos();

  /// Obtiene la lista de contratistas filtrada por el ID del proyecto.
  Future<List<Map<String, dynamic>>> getContratistasPorProyecto(int proyectoId);
}