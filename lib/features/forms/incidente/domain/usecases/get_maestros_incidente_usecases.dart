

import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

class GetProyectosIncidenteUseCase {
  final IncidenteRepository repository;
  GetProyectosIncidenteUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getProyectos();
  }
}