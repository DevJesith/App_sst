// features/forms/capacitacion/data/repositories_impl/capacitacion_repository_impl.dart

import 'package:app_sst/features/forms/capacitacion/data/datasources/capacitacion_local_datasources.dart';
import 'package:app_sst/features/forms/capacitacion/data/model/capacitacion_model.dart';

import '../../domain/entities/capacitacion.dart';
import '../../domain/repositories/capacitacion_repository.dart';


class CapacitacionRepositoryImpl implements CapacitacionRepository {
  final CapacitacionLocalDataSource localDataSource;

  CapacitacionRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Capacitacion>> getCapacitaciones() async {
    try {
      return await localDataSource.getCapacitaciones();
    } catch (e) {
      throw Exception('Error al obtener capacitaciones: $e');
    }
  }

  @override
  Future<Capacitacion?> getCapacitacionById(int id) async {
    try {
      return await localDataSource.getCapacitacionById(id);
    } catch (e) {
      throw Exception('Error al obtener capacitación: $e');
    }
  }

  @override
  Future<List<Capacitacion>> getCapacitacionesByUsuario(int usuarioId) async {
    try {
      return await localDataSource.getCapacitacionesByUsuario(usuarioId);
    } catch (e) {
      throw Exception('Error al obtener capacitaciones del usuario: $e');
    }
  }

  @override
  Future<int> createCapacitacion(Capacitacion capacitacion) async {
    try {
      final model = CapacitacionModel(
        idProyecto: capacitacion.idProyecto,
        idContratista: capacitacion.idContratista,
        descripcion: capacitacion.descripcion,
        numeroCapacita: capacitacion.numeroCapacita,
        numeroPersonas: capacitacion.numeroPersonas,
        responsable: capacitacion.responsable,
        fechaRegistro: capacitacion.fechaRegistro,
        sincronizado: capacitacion.sincronizado,
        usuarioId: capacitacion.usuarioId,
      );
      return await localDataSource.insertCapacitacion(model);
    } catch (e) {
      throw Exception('Error al crear capacitación: $e');
    }
  }

  @override
  Future<int> updateCapacitacion(Capacitacion capacitacion) async {
    try {
      final model = CapacitacionModel(
        id: capacitacion.id,
        idProyecto: capacitacion.idProyecto,
        idContratista: capacitacion.idContratista,
        descripcion: capacitacion.descripcion,
        numeroCapacita: capacitacion.numeroCapacita,
        numeroPersonas: capacitacion.numeroPersonas,
        responsable: capacitacion.responsable,
        fechaRegistro: capacitacion.fechaRegistro,
        sincronizado: capacitacion.sincronizado,
        usuarioId: capacitacion.usuarioId,
      );
      return await localDataSource.updateCapacitacion(model);
    } catch (e) {
      throw Exception('Error al actualizar capacitación: $e');
    }
  }

  @override
  Future<int> deleteCapacitacion(int id) async {
    try {
      return await localDataSource.deleteCapacitacion(id);
    } catch (e) {
      throw Exception('Error al eliminar capacitación: $e');
    }
  }
}