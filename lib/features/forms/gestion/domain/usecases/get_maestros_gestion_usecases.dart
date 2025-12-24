
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

class GetProyectosGestionUseCase {
  final GestionRepository repository;
  GetProyectosGestionUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getProyectos();
  }
}