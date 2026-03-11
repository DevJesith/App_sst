import 'package:app_sst/features/pqrs/domain/repositories/pqrs_repository.dart';

class ResolverPqrsUsecases {
  final PqrsRepository repository;

  ResolverPqrsUsecases(this.repository);

  Future<void> call(int id) async => await repository.marcarComoResuelto(id);
}
