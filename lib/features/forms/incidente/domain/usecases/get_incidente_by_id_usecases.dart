

import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

class GetIncidenteByIdUsecases {
  final IncidenteRepository repository;

  GetIncidenteByIdUsecases(this.repository);

  Future<Incidente?> call(int id) async {
    return await repository.getIncidenteById(id);
  } 
}