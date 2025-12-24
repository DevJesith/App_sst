
import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';

class GetProyectosCapacitacionUseCase {
  final CapacitacionRepository repository;
  GetProyectosCapacitacionUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getProyectos();
  }
}

class GetContratistasCapacitacionUseCase {
  final CapacitacionRepository repository;
  GetContratistasCapacitacionUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(int proyectoId) async {
    return await repository.getContratistasPorProyecto(proyectoId);
  }
}