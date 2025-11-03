import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';
import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';

class ActualizarAccidenteUsecases {
  final AccidenteRepository repository;

  ActualizarAccidenteUsecases(this.repository);

  Future<int> call(Accidente accidente) async {
    return await repository.actualizarAccidente(accidente);
  }
}