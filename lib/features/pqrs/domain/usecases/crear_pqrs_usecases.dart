import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';
import 'package:app_sst/features/pqrs/domain/repositories/pqrs_repository.dart';

class CrearPqrsUsecases {
  final PqrsRepository repository;

  CrearPqrsUsecases(this.repository);

  Future<void> call(Pqrs pqrs) async => await repository.crearPqrs(pqrs);
}
