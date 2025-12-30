import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

/// Caso de uso para obtener la lista de Proyectos disponibles.
/// Se utiliza para llenar el Dropdown del formulario de Incidente.
class GetProyectosIncidenteUseCase {
  final IncidenteRepository repository;
  GetProyectosIncidenteUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getProyectos();
  }
}