import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';
import 'package:app_sst/features/pqrs/domain/repositories/pqrs_repository.dart';

/// Caso de uso para listar todos las pqrs registradas
class GetPqrsUsecase {
  final PqrsRepository repositoy;

  GetPqrsUsecase(this.repositoy);

  /// Retorna la lista completa de pqrs ordenados por fecha
  Future<List<Pqrs>> call() async => await repositoy.obtenerTodos();
}
