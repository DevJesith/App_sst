
import 'package:app_sst/features/forms/capacitacion/domain/entities/capacitacion.dart';
import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

class GetCapacitacionByIdUsecases {
  
  final CapacitacionRepository repository;

  GetCapacitacionByIdUsecases(this.repository);

  Future<Capacitacion?> call(int id) async {
    return await repository.getCapacitacionById(id);
  }
}