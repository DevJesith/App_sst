import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';
import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';

/// Caso de uso para modificar un reporte de accidente existente.
class ActualizarAccidenteUsecases {
  final AccidenteRepository repository;

  ActualizarAccidenteUsecases(this.repository);

  /// Actualiza los datos en la BD.
  /// Retorna el numero de filas afectadas
  Future<int> call(Accidente accidente) async {
    return await repository.actualizarAccidente(accidente);
  }
}