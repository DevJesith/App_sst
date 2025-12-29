import 'package:app_sst/features/forms/capacitacion/domain/entities/capacitacion.dart';
import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

///Caso de uso para registrar una nueva capacitacion
class CreateCapacitacionUsecases {
  final CapacitacionRepository repository;

  CreateCapacitacionUsecases(this.repository);

  /// Guarda la capacitacion y retorna ID generadp
  Future<int> call(Capacitacion capacitacion) async {
    return await repository.createCapacitacion(capacitacion);
  }
}