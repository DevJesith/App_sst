import 'package:app_sst/features/forms/capacitacion/domain/entities/capacitacion.dart';
import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

/// Caso de uso para modificar un registro existente
class ActualizarCapacitacionUsecases {
  final CapacitacionRepository repository;

  ActualizarCapacitacionUsecases(this.repository);

  /// Actualiza los datos de la capacitacion en la BD.
  Future<int> call(Capacitacion capacitacion) async {
    return await repository.updateCapacitacion(capacitacion);
  }
}