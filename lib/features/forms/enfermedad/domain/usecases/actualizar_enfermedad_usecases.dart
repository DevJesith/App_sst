
import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

class ActualizarEnfermedadUsecases {
  final EnfermedadRepository repository;

  ActualizarEnfermedadUsecases(this.repository);

  Future<int> call(Enfermedad enfermedad) async {
    return await repository.actualizarEnfermedad(enfermedad);
  }
}