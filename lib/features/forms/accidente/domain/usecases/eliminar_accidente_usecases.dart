import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';

class EliminarAccidenteUsecases {
  final AccidenteRepository repository;

  EliminarAccidenteUsecases(this.repository);

  Future<int> call(int id) async {
    return await repository.eliminarAccidente(id);
  }
}