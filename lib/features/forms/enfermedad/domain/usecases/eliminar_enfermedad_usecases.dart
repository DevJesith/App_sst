import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

/// Caso de uso para eliminar un reporte
class EliminarEnfermedadUsecases {
  final EnfermedadRepository repository;

  EliminarEnfermedadUsecases(this.repository);

  /// Elimina el registro identificado por [id].
  Future<int> call(int id) async {
    return await repository.eliminarEnfermedad(id);
  }
}