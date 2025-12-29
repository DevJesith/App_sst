import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';

/// Caso de usp ára eliminar un reporte de accidente
class EliminarAccidenteUsecases {
  final AccidenteRepository repository;

  EliminarAccidenteUsecases(this.repository);

  /// Elimina el registro identificado por [id]
  Future<int> call(int id) async {
    return await repository.eliminarAccidente(id);
  }
}