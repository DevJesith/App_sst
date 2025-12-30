import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

/// Caso de uso para listar todos los reportes registrados
class GetEnfermedadUsecases {
  final EnfermedadRepository repository;

  GetEnfermedadUsecases(this.repository);

  /// Retorna la lista completa de enfermedades ordenadas por fecha.
  Future<List<Enfermedad>> call() async {
    return await repository.getEnfermedad();
  }
}