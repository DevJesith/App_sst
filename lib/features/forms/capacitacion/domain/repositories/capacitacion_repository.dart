// features/forms/capacitacion/domain/repositories/capacitacion_repository.dart

import '../entities/capacitacion.dart';

abstract class CapacitacionRepository {
  Future<List<Capacitacion>> getCapacitaciones();
  Future<Capacitacion?> getCapacitacionById(int id);
  Future<List<Capacitacion>> getCapacitacionesByUsuario(int usuarioId);
  Future<int> createCapacitacion(Capacitacion capacitacion);
  Future<int> updateCapacitacion(Capacitacion capacitacion);
  Future<int> deleteCapacitacion(int id);
  Future<List<Map<String, dynamic>>> getProyectos();
  Future<List<Map<String, dynamic>>> getContratistasPorProyecto(int proyectoId);
}