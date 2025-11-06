

import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

class EliminarIncidenteUsecases {
  final IncidenteRepository repository;

  EliminarIncidenteUsecases(this.repository);

  Future<int> call(int id) async {
    return await repository.eliminarIncidente(id);
  }
}