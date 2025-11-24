
import 'package:app_sst/features/forms/incidente/data/datasources/incidente_local_datasource.dart';
import 'package:app_sst/features/forms/incidente/data/model/incidente_model.dart';
import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';

class IncidenteRepositoryImpl implements IncidenteRepository {
  final IncidenteLocalDatasource localDatasource;

  IncidenteRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Incidente>> getIncidente() async{
    try {
      return await localDatasource.getIncidentes();
    } catch (e) {
      throw Exception('Error al obtener incidente: $e');
    }
  }

  @override
  Future<Incidente?> getIncidenteById(int id) async {
    try {
      return await localDatasource.getIncidenteById(id);
    } catch (e) {
      throw Exception('Error al obtener incidente: $e');
    }
  }

  @override
  Future<List<Incidente>> getIncidenteByUsuario(int usuarioId) async {
    try {
      return await localDatasource.getIncidenteByUsuario(usuarioId);
    } catch (e) {
      throw Exception('Error al obtener incidentes del usuario: $e');
    }
  }

  @override
  Future<int> crearIncidente(Incidente incidente) async {
    try {
      final model = IncidenteModel(
      eventualidad: incidente.eventualidad, 
      proyecto: incidente.proyecto, 
      mes: incidente.mes, 
      descripcion: incidente.descripcion, 
      diasIncapacidad: incidente.diasIncapacidad, 
      avances: incidente.avances, 
      estado: incidente.estado, 
      fechaRegistro: incidente.fechaRegistro, 
      usuarioId: incidente.usuarioId);
      return await localDatasource.crearIncidente(model);
    } catch (e) {
      throw Exception('Error añ crear incidentes: $e');
    }
  }

  @override
  Future<int> actualizarIncidente(Incidente incidente) async {
    try {
      final model = IncidenteModel(
      eventualidad: incidente.eventualidad, 
      proyecto: incidente.proyecto, 
      mes: incidente.mes, 
      descripcion: incidente.descripcion, 
      diasIncapacidad: incidente.diasIncapacidad, 
      avances: incidente.avances, 
      estado: incidente.estado, 
      fechaRegistro: incidente.fechaRegistro, 
      usuarioId: incidente.usuarioId);
      return await localDatasource.actualizarIncidente(model);
    } catch (e) {
      throw Exception('Error al actualizar incidentes: $e');
    }
  }

  @override
  Future<int> eliminarIncidente(int id) async {
    try {
      return await localDatasource.eliminarIncidente(id);
    } catch (e) {
      throw Exception('Error al eliminar incidentes: $e');
    }
  }
}