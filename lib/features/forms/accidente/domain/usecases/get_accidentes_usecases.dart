

import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';
import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';

class GetAccidentesUsecases {
  final AccidenteRepository repository;

  GetAccidentesUsecases(this.repository);

  Future<List<Accidente>> call() async {
    return await repository.getAccidentes();
  }
}