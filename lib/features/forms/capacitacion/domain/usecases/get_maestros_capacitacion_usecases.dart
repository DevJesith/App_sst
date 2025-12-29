import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

/// Caso de uso para obtener la lista de proyectos disponible.
/// Sed utiliza para llenar el primer Dropdown del formulario.
class GetProyectosCapacitacionUseCase {
  final CapacitacionRepository repository;
  GetProyectosCapacitacionUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getProyectos();
  }
}

/// Caso de uso para obtener la lista de Contratistas filtrada por Proyecto.
/// Se utiliza para llenar el segundo Dropdwn. 
class GetContratistasCapacitacionUseCase {
  final CapacitacionRepository repository;
  GetContratistasCapacitacionUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(int proyectoId) async {
    return await repository.getContratistasPorProyecto(proyectoId);
  }
}