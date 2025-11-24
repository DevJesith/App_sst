
import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

class EliminarCapacitacionUsecases {
  final CapacitacionRepository repository;

  EliminarCapacitacionUsecases(this.repository);

  Future<int> call(int id) async {
    return await repository.deleteCapacitacion(id);
  }
}