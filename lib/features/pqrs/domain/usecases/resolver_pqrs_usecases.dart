import 'package:app_sst/features/pqrs/domain/repositories/pqrs_repository.dart';

/// Caso de uso para resolver todas las pqrs
class ResolverPqrsUsecases {
  final PqrsRepository repository;

  ResolverPqrsUsecases(this.repository);

  /// Resuelve la PQRS especificada por su [id].
  Future<void> call(int id) async => await repository.marcarComoResuelto(id);
}
