
import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

class CrearGestionUsecases {
  final GestionRepository repository;

  CrearGestionUsecases(this.repository);

  Future<int> call(Gestion gestion) async {
    return await repository.crearGestion(gestion);
  }
}