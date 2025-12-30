import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

/// Caso de uso para modificar un reporte existente
class ActualizarIncidenteUsecases {
  final IncidenteRepository repository;

  ActualizarIncidenteUsecases(this.repository);

  /// Actualiza los datos del incidente en la base de datos.
  Future<int> call(Incidente incidente) async {
    return await repository.actualizarIncidente(incidente);
  }
}