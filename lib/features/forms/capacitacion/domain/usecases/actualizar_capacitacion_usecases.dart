
import 'package:app_sst/features/forms/capacitacion/domain/entities/capacitacion.dart';
import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

class ActualizarCapacitacionUsecases {
  final CapacitacionRepository repository;

  ActualizarCapacitacionUsecases(this.repository);

  Future<int> call(Capacitacion capacitacion) async {
    return await repository.updateCapacitacion(capacitacion);
  }
}