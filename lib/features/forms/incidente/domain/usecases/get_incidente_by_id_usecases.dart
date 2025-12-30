import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

/// Caso de uso para obtener el detalle de un incidente especifico.
class GetIncidenteByIdUsecases {
  final IncidenteRepository repository;

  GetIncidenteByIdUsecases(this.repository);

  /// Busca un reporte por su [id]. Retorna null si no existe
  Future<Incidente?> call(int id) async {
    return await repository.getIncidenteById(id);
  } 
}