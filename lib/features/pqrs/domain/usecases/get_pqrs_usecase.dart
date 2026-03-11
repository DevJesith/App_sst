import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';
import 'package:app_sst/features/pqrs/domain/repositories/pqrs_repository.dart';

class GetPqrsUsecase {
  final PqrsRepository repositoy;

  GetPqrsUsecase(this.repositoy);

  Future<List<Pqrs>> call() async => await repositoy.obtenerTodos();
}
