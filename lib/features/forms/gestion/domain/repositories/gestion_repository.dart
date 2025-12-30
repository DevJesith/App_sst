import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';

/// Contrato (interface) para el manejo de datos.
/// 
/// Define las operaciones que la capa de datos debe implementar,
/// incluyendo el CRUD y la obtencion de proyectos para el formulario.
abstract class GestionRepository {

  /// Obtiene todos los reportes de gestion registrados.
  Future<List<Gestion>> getGestiones();

  /// Busca un reporte por su ID
  Future<Gestion?> getGestionById(int id);

  /// Obtiene los reportes creados por un usuario especifico.
  Future<List<Gestion>> getGestionesByUsuario(int usuarioId);

  /// Guarda un nuevo reporte de gestion.
  Future<int> crearGestion(Gestion gestion);

  /// Actualiza un reporte existente.
  Future<int> actualizarGestion(Gestion gestion);

  /// Elimina un reporte por su ID
  Future<int> eliminarGestion(int id);

  /// Obtiene la lista de proyectos disponibles.
  Future<List<Map<String, dynamic>>> getProyectos();
}