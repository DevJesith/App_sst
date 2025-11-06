

import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

class GetIncidenteUsecases {
  final IncidenteRepository repository;

  GetIncidenteUsecases(this.repository);

  Future<List<Incidente>> call() async {
    return await repository.getIncidente();
  }
}