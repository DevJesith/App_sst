import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

/// Caso de uso para registrar un nuevo formulario
class CrearEnfermedadUsecases {
  final EnfermedadRepository repository;

  CrearEnfermedadUsecases(this.repository);

  /// Guarda el reporte y retorna ID generado.
  Future<int> call(Enfermedad enfermedad) async {
    return await repository.crearEnfermedad(enfermedad);
  }
}