import '../repositories/accidente_repository.dart';

/// Caso de uso para obetner la lista de Proyectos disponibles.
/// Se utiliza para llenar el primer Dropdown del formulario.
class GetProyectosUseCase {
  final AccidenteRepository repository;
  GetProyectosUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getProyectos();
  }
}

/// Caso de uso para obtener la lista de Contratistas filtrada por Proyecto.
/// Se utiliza para llenar el segundo Dropdown
class GetContratistasPorProyectoUseCase {
  final AccidenteRepository repository;
  GetContratistasPorProyectoUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(int proyectoId) async {
    return await repository.getContratistasPorProyectos(proyectoId);
  }
}

/// Caso de uso para obtener la lista de todos los Contratistas.
class GetAllContratistasUseCase {
  final AccidenteRepository repository;
  GetAllContratistasUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getAllContratistas();
  }
}