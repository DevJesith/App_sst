import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

/// Caso de uso para eliminar un reporte.
class EliminarIncidenteUsecases {
  final IncidenteRepository repository;

  EliminarIncidenteUsecases(this.repository);

  /// Elimina el registro identificado por [id].
  Future<int> call(int id) async {
    return await repository.eliminarIncidente(id);
  }
}