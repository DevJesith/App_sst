import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';

/// Contrato (Interface) para el manejo de datos de Accidentes
/// 
/// Define que operacion debe implementar la capa de datos,
/// desacoplando la logica de negocio de la base de datos especificas.
abstract class AccidenteRepository {

  /// Obtiene todos los accidentes registrados
  Future<List<Accidente>> getAccidentes();

  /// Busca un accidente por su ID unico
  Future<Accidente?> getAccidenteById(int id);

  /// Obtiene los accidentes creados por un usuario especifico.
  Future<List<Accidente>> getAccidenteByUsuario(int usuarioId);

  /// Guarda un nuevo accidente en el almacenamiento
  Future<int> crearAccidente(Accidente accidente);

  /// Actualiza un accidente existente
  Future<int> actualizarAccidente(Accidente accidente);

  /// Elimina un accidente del almacenamiento
  Future<int> eliminarAccidente(int id);

  /// Obtiene la lista de proyectos
  Future<List<Map<String, dynamic>>> getProyectos();

  /// Obtiene la lista de contratistas filtrada por el ID del proyecto
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectoId);

  // Obtiene la lista de todos los contratistas
  Future<List<Map<String, dynamic>>> getAllContratistas();
}