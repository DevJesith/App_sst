import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';

/// Contrato (interface) para el manejo de datos 
/// 
/// Define las operaciones que la capa de datos debe implementar,
/// incluyendo el CRUD y las consultas para los dropwns en cascada.
abstract class EnfermedadRepository {

  /// Obtiene todos los reportes
  Future<List<Enfermedad>> getEnfermedad();

  /// Busca un reporte por su ID
  Future<Enfermedad?> getEnfermedadById(int id);

  /// Obtiene los reportes creados por un usuario especifico
  Future<List<Enfermedad>> getEnfermedadByUsuario(int usuarioId);

  /// Guarda un nuevo reporte de enfermedad.
  Future<int> crearEnfermedad(Enfermedad enfermedad);

  /// Actualiza un reporte existente
  Future<int> actualizarEnfermedad(Enfermedad enfermedad);

  /// Elimina un reporte por su ID
  Future<int> eliminarEnfermedad(int id);

  /// Obtiene la listade proyectos disponibles.
  Future<List<Map<String, dynamic>>> getProyectos();

  /// Obtiene la lista de contratistas filtrada por proyecto.
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectoId);

  /// Obtiene la lista de trabajadores filtrada por proyecto y contratista.
  Future<List<Map<String, dynamic>>> getTrabajadoresPorContratista(int proyectoId, int contratistaId);
}