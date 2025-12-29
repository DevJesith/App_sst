import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';
import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';


/// Caso de uso para registrar un nuevo accidente
class CrearAccidenteUsecases {
  final AccidenteRepository repository;

  CrearAccidenteUsecases(this.repository);

  /// Guarda el accidente y retorna el ID generado
  Future<int> call(Accidente accidente) async {
    return await repository.crearAccidente(accidente);
  }
}
