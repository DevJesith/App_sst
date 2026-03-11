import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';
import 'package:app_sst/features/pqrs/domain/repositories/pqrs_repository.dart';

/// Caso de uso para registrar un nuevo pqrs
class CrearPqrsUsecases {
  final PqrsRepository repository;

  CrearPqrsUsecases(this.repository);

  /// Guarda la pqrs y retorna el id generado
  Future<void> call(Pqrs pqrs) async => await repository.crearPqrs(pqrs);
}
