import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

/// Caso de uso para listar todos los reportes de incidente registrado.
class GetIncidenteUsecases {
  final IncidenteRepository repository;

  GetIncidenteUsecases(this.repository);

  /// Retorna la lista completa de incidentes ordenados por fecha.
  Future<List<Incidente>> call() async {
    return await repository.getIncidente();
  }
}