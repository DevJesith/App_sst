import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

/// Caso de uso para registrar nueva gestion
class CrearGestionUsecases {
  final GestionRepository repository;

  CrearGestionUsecases(this.repository);

  /// Guarda el reporte y retorna el ID generado.
  Future<int> call(Gestion gestion) async {
    return await repository.crearGestion(gestion);
  }
}