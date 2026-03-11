import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';

/// Contrato (Interface) para el manejo de datos de PQRS
/// 
/// Define que operacion debe implementar la capa de datos,
/// desacoplando la logica de negocio de la base de datos
/// 
abstract class PqrsRepository {

  // Guarda un nuevo pqrs en el almacenamiento
  Future<void> crearPqrs(Pqrs pqrs);

  /// Obtiene la lista de todos los pqrs 
  Future<List<Pqrs>> obtenerTodos();

  /// Actualiza el estado de la pqrs
  Future<void> marcarComoResuelto(int id);
}
