import 'package:app_sst/features/forms/capacitacion/domain/entities/capacitacion.dart';
import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

/// Caso de uso para obtener el detalle de una capacitacion
class GetCapacitacionByIdUsecases {
  
  final CapacitacionRepository repository;

  GetCapacitacionByIdUsecases(this.repository);

  /// Busca una capacitacion por su [id]. Retorna null si no existe.
  Future<Capacitacion?> call(int id) async {
    return await repository.getCapacitacionById(id);
  }
}