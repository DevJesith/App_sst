import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

/// Caso de uso para obtener el detalle de una gestion especifica.
class GetGestionByIdUsecases {
  final GestionRepository repository;

  GetGestionByIdUsecases(this.repository);

  /// Busca un reporte por su [id]. Retorna null si no existe.
  Future<Gestion?> call(int id) async {
    return await repository.getGestionById(id);
  }
}