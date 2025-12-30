import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

/// Caso de uso para registrar un nuevo incidente en el sistema
class CrearIncidenteUsecases {
  final IncidenteRepository repository;

  CrearIncidenteUsecases(this.repository);

  /// Guarda el reporte y retorna el ID generado.
  Future<int> call(Incidente incidente) async {
    return await repository.crearIncidente(incidente);
  }
}