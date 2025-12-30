import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

/// Caso de uso para modificar un reporte existente
class ActualizarEnfermedadUsecases {
  final EnfermedadRepository repository;

  ActualizarEnfermedadUsecases(this.repository);

  /// Actualiza los datos de la enfermedad en la BD.
  Future<int> call(Enfermedad enfermedad) async {
    return await repository.actualizarEnfermedad(enfermedad);
  }
}