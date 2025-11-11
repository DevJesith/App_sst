
import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

class GetEnfermedadByIdUsecases {
  final EnfermedadRepository repository;

  GetEnfermedadByIdUsecases(this.repository);

  Future<Enfermedad?> call(int id) async {
    return await repository.getEnfermedadById(id);
  }
}