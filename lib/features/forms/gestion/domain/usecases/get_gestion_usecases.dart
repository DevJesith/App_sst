

import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

class GetGestionUsecases {
  final GestionRepository repository;

  GetGestionUsecases(this.repository);

  Future<List<Gestion>> call() async {
    return await repository.getGestiones();
  }
}