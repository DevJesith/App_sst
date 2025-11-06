
import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

class ActualizarIncidenteUsecases {
  final IncidenteRepository repository;

  ActualizarIncidenteUsecases(this.repository);

  Future<int> call(Incidente incidente) async {
    return await repository.actualizarIncidente(incidente);
  }
}