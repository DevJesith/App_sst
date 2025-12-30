import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';

/// Contrato (Interface) para el manejo de datos.
/// 
/// Define las operaciones que la capa de datos debe implementar,
/// incluyendo el CRUD y la obtencion de proyectos para el formulario.
abstract class IncidenteRepository {

  /// Busca un incidente por su ID
  Future<List<Incidente>> getIncidente();

  /// Obtiene los incidentes creados por su ID.
  Future<Incidente?> getIncidenteById(int id);

  /// Obtiene los incidentes creado por un usuario especifico.
  Future<List<Incidente>> getIncidenteByUsuario(int usuarioId);

  /// Guarda un nuevo reporte de incidente
  Future<int> crearIncidente(Incidente incidente);

  /// Actualiza un reporte existente.
  Future<int> actualizarIncidente(Incidente incidente);

  /// Elimina un reporte por su ID
  Future<int> eliminarIncidente(int id);

  /// Obtiene la lista de proyectos disponibles.
  Future<List<Map<String, dynamic>>> getProyectos();
}