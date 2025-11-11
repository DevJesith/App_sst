
import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

class GetEnfermedadUsecases {
  final EnfermedadRepository repository;

  GetEnfermedadUsecases(this.repository);

  Future<List<Enfermedad>> call() async {
    return await repository.getEnfermedad();
  }
}