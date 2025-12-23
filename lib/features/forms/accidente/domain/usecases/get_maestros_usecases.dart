import '../repositories/accidente_repository.dart';

class GetProyectosUseCase {
  final AccidenteRepository repository;
  GetProyectosUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getProyectos();
  }
}

class GetContratistasPorProyectoUseCase {
  final AccidenteRepository repository;
  GetContratistasPorProyectoUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(int proyectoId) async {
    return await repository.getContratistasPorProyectos(proyectoId);
  }
}