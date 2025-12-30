import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

/// Caso de uso para modificar un reporte existente
class ActualizarGestionUsecases {
  final GestionRepository repository;

  ActualizarGestionUsecases(this.repository);

  /// Actualiza los datos de la gestion BD.
  Future<int> call(Gestion gestion) async{
    return await repository.actualizarGestion(gestion);
  }
}