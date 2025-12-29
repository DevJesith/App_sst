import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';
import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';

/// Caso de uso para obtener el detalle de un accidente especifico.
class GetAccidenteByIdUsecases {
  final AccidenteRepository repository;

  GetAccidenteByIdUsecases(this.repository);

  /// Busca un accidente por su [id]. Retorna null si no existe
  Future<Accidente?> call(int id) async {
    return await repository.getAccidenteById(id);
  }
}