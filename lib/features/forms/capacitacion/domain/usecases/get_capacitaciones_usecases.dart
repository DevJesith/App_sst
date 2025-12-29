
import 'package:app_sst/features/forms/capacitacion/domain/entities/capacitacion.dart';
import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

/// Caso de uso para listar todas las capacitaciones registradas.
class GetCapacitacionesUsecases {
  final CapacitacionRepository repository;

  GetCapacitacionesUsecases(this.repository);

  /// Retorna la lista completa de capacitaciones ordenadas por fecha
  Future<List<Capacitacion>> call() async {
    return await repository.getCapacitaciones();
  }
}