

import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

class CrearIncidenteUsecases {
  final IncidenteRepository repository;

  CrearIncidenteUsecases(this.repository);

  Future<int> call(Incidente incidente) async {
    return await repository.crearIncidente(incidente);
  }
}