import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';
import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';

class GetAccidenteByIdUsecases {
  final AccidenteRepository repository;

  GetAccidenteByIdUsecases(this.repository);

  Future<Accidente?> call(int id) async {
    return await repository.getAccidenteById(id);
  }
}