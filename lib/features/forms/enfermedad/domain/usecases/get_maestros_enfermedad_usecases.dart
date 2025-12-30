import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

/// Caso de uso para obtener la lista de Proyectos disponibles.
class GetProyectosEnfermedadUseCase {
  final EnfermedadRepository repository;
  GetProyectosEnfermedadUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() => repository.getProyectos();
}

/// Caso de uso para obtener la lista de contratistas filtrada por Proyecto
class GetContratistasEnfermedadesUseCase {
  final EnfermedadRepository repository;
  GetContratistasEnfermedadesUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(int proyectoId) => repository.getContratistasPorProyectos(proyectoId);
}

/// Caso de uso para obtener la lista de Trabajadores filtrada por Contratista.
class GetTrabajadoresEnfermedadUseCase {
  final EnfermedadRepository repository;
  GetTrabajadoresEnfermedadUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(int proyectoId, int contratistaId) => repository.getTrabajadoresPorContratista(proyectoId, contratistaId);
}