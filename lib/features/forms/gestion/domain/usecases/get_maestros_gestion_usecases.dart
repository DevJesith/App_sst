import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

/// Caso de uso para obtener la lista de Proyectos disponibles.
/// Se utiliza para llenar el Dropdown del formulario.
class GetProyectosGestionUseCase {
  final GestionRepository repository;
  GetProyectosGestionUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getProyectos();
  }
}