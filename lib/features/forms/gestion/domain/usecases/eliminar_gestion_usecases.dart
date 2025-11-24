

import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

class EliminarGestionUsecases {
  final GestionRepository repository;

  EliminarGestionUsecases(this.repository);

  Future<int> call(int id) async {
    return await repository.eliminarGestion(id);
  }
}