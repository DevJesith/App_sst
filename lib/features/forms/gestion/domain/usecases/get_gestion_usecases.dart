import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

/// Caso de uso para listar todos los reportes.
class GetGestionUsecases {
  final GestionRepository repository;

  GetGestionUsecases(this.repository);

  /// Retorna la lista completa de gestiones ordenadas por fecha.
  Future<List<Gestion>> call() async {
    return await repository.getGestiones();
  }
}