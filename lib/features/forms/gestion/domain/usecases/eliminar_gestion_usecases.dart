import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

/// Caso de uso para eliminar un reporte.
class EliminarGestionUsecases {
  final GestionRepository repository;

  EliminarGestionUsecases(this.repository);

  /// Elimina el registro identificada por [id]
  Future<int> call(int id) async {
    return await repository.eliminarGestion(id);
  }
}