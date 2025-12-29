import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

/// Caso de uso para eliminar un registro
class EliminarCapacitacionUsecases {
  final CapacitacionRepository repository;

  EliminarCapacitacionUsecases(this.repository);

  /// Elimina el registro identificado por [id]
  Future<int> call(int id) async {
    return await repository.deleteCapacitacion(id);
  }
}