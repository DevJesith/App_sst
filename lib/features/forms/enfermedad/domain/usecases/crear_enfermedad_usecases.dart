
import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

class CrearEnfermedadUsecases {
  final EnfermedadRepository repository;

  CrearEnfermedadUsecases(this.repository);

  Future<int> call(Enfermedad enfermedad) async {
    return await repository.crearEnfermedad(enfermedad);
  }
}