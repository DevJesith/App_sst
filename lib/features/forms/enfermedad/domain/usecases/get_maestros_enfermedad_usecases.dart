

import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

class GetProyectosEnfermedadUseCase {
  final EnfermedadRepository repository;
  GetProyectosEnfermedadUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() => repository.getProyectos();
}

class GetContratistasEnfermedadesUseCase {
  final EnfermedadRepository repository;
  GetContratistasEnfermedadesUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(int proyectoId) => repository.getContratistasPorProyectos(proyectoId);
}

class GetTrabajadoresEnfermedadUseCase {
  final EnfermedadRepository repository;
  GetTrabajadoresEnfermedadUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(int proyectoId, int contratistaId) => repository.getTrabajadoresPorContratista(proyectoId, contratistaId);
}