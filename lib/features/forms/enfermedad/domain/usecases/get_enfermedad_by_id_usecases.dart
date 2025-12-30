import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

/// Caso de uso para obtener el detalle de una enfermedad especifica.
class GetEnfermedadByIdUsecases {
  final EnfermedadRepository repository;

  GetEnfermedadByIdUsecases(this.repository);

  /// Busca un reporte por su [id]. Retorna null si no existe
  Future<Enfermedad?> call(int id) async {
    return await repository.getEnfermedadById(id);
  }
}