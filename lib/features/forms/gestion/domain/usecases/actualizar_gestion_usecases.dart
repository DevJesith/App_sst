

import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

class ActualizarGestionUsecases {
  final GestionRepository repository;

  ActualizarGestionUsecases(this.repository);

  Future<int> call(Gestion gestion) async{
    return await repository.actualizarGestion(gestion);
  }
}