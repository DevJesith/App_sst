

import 'package:app_sst/features/forms/enfermedad/data/datasources/enfermedad_local_datasource.dart';
import 'package:app_sst/features/forms/enfermedad/data/model/enfermedad_model.dart';
import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';

class EnfermedadRepositoryImpl implements EnfermedadRepository {
  final EnfermedadLocalDatasource localDatasource;

  EnfermedadRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Enfermedad>> getEnfermedad() async {
    try {
      return await localDatasource.getEnfermedad();
    } catch (e) {
      throw Exception('Error al obtener enfermedad: $e');
    }
  }

  @override
  Future<Enfermedad?> getEnfermedadById(int id) async {
    try {
      return await localDatasource.getEnfermedadById(id);
    } catch (e) {
      throw Exception('Error al obtener enfermedad: $e');
    }
  }

  @override
  Future<List<Enfermedad>> getEnfermedadByUsuario(int usuarioId) async {
    try {
      return await localDatasource.getEnfermedadByUsuario(usuarioId);
    } catch (e) {
      throw Exception('Error al obtener enfermedad del usuario: $e');
    }
  }

  @override
  Future<int> crearEnfermedad(Enfermedad enfermedad) async {
    try {
      final model = EnfermedadModel(
      eventualidad: enfermedad.eventualidad, 
      proyectoId: enfermedad.proyectoId, 
      contratistaId: enfermedad.contratistaId, 
      trabajadorId: enfermedad.trabajadorId,
      mes: enfermedad.mes, 
      descripcion: enfermedad.descripcion, 
      diasIncapacidad: enfermedad.diasIncapacidad, 
      avances: enfermedad.avances, 
      estado: enfermedad.estado, 
      fechaRegistro: enfermedad.fechaRegistro, 
      usuarioId: enfermedad.usuarioId
      );
      return await localDatasource.crearEnfermedad(model);
    } catch (e) {
      throw Exception('Error al crear enfermedad: $e');
    }
  }

  @override
  Future<int> actualizarEnfermedad(Enfermedad enfermedad) async {
    try {
      final model = EnfermedadModel(
      id: enfermedad.id,
      eventualidad: enfermedad.eventualidad, 
      proyectoId: enfermedad.proyectoId, 
      contratistaId: enfermedad.contratistaId, 
      trabajadorId: enfermedad.trabajadorId,
      mes: enfermedad.mes, 
      descripcion: enfermedad.descripcion, 
      diasIncapacidad: enfermedad.diasIncapacidad, 
      avances: enfermedad.avances, 
      estado: enfermedad.estado, 
      fechaRegistro: enfermedad.fechaRegistro, 
      usuarioId: enfermedad.usuarioId
      );
      return await localDatasource.actualizarEnfermedad(model);
    } catch (e) {
      throw Exception('Error al actualizar enfermedad: $e');
    }
  }

  @override
  Future<int> eliminarEnfermedad(int id) async {
    try {
      return await localDatasource.eliminarEnfermedad(id);
    } catch (e) {
      throw Exception('Error al eliminar enfermedad: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProyectos() async {
    return await localDatasource.getProyectos();
  }

  @override
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectoId) async{
    return await localDatasource.getContratistasPorProyectos(proyectoId);
  }

  @override
  Future<List<Map<String, dynamic>>> getTrabajadoresPorContratista(int proyectoId, int contratistaId) async{
    return await localDatasource.getTrabajadoresPorContratista(proyectoId, contratistaId);
  }
}