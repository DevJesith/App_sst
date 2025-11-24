

import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

class GetGestionByIdUsecases {
  final GestionRepository repository;

  GetGestionByIdUsecases(this.repository);

  Future<Gestion?> call(int id) async {
    return await repository.getGestionById(id);
  }
}