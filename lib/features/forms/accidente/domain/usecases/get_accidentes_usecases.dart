import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';
import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';

/// Caso de uso para listar todos los accidentes registrados.
class GetAccidentesUsecases {
  final AccidenteRepository repository;

  GetAccidentesUsecases(this.repository);

  /// Retorna la lista completa de accidentes ordenados por fecha.
  Future<List<Accidente>> call() async {
    return await repository.getAccidentes();
  }
}