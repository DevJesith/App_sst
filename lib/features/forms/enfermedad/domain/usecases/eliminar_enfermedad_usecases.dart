
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

class EliminarEnfermedadUsecases {
  final EnfermedadRepository repository;

  EliminarEnfermedadUsecases(this.repository);

  Future<int> call(int id) async {
    return await repository.eliminarEnfermedad(id);
  }
}