
import 'package:app_sst/features/forms/capacitacion/domain/entities/capacitacion.dart';
import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

class GetCapacitacionesUsecases {
  final CapacitacionRepository repository;

  GetCapacitacionesUsecases(this.repository);

  Future<List<Capacitacion>> call() async {
    return await repository.getCapacitaciones();
  }
}