import '../../domain/entities/accidente.dart';
import '../../domain/repositories/accidente_repository.dart';
import '../datasources/accidente_local_datasource.dart';
import '../model/accidente_model.dart';

class AccidenteRepositoryImpl implements AccidenteRepository {
  final AccidenteLocalDatasource localDatasource;

  AccidenteRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Accidente>> getAccidentes() async {
    try {
      return await localDatasource.getAccidentes();
    } catch (e) {
      throw Exception('Error al obtener accidentes: $e');
    }
  }

  @override
  Future<Accidente?> getAccidenteById(int id) async {
    try {
      return await localDatasource.getAccidenteById(id);
    } catch (e) {
      throw Exception('Error al obtener accidente: $e');
    }
  }

  @override
  Future<List<Accidente>> getAccidenteByUsuario(int usuarioId) async {
    try {
      return await localDatasource.getAccidenteByUsuario(usuarioId);
    } catch (e) {
      throw Exception('Error al obtener accidentes del usuario: $e');
    }
  }

  @override
  Future<int> crearAccidente(Accidente accidente) async {
    try {
      final model = AccidenteModel(
        eventualidad: accidente.eventualidad,
        proyecto: accidente.proyecto,
        contratista: accidente.contratista,
        mes: accidente.mes,
        descripcion: accidente.descripcion,
        diasIncapacidad: accidente.diasIncapacidad,
        avances: accidente.avances,
        estado: accidente.estado,
        fechaRegistro: accidente.fechaRegistro,
        sincronizado: accidente.sincronizado,
        usuarioId: accidente.usuarioId,
      );
      return await localDatasource.crearAccidente(model);
    } catch (e) {
      throw Exception('Error al crear accidente: $e');
    }
  }

  @override
  Future<int> actualizarAccidente(Accidente accidente) async {
    try {
      final model = AccidenteModel(
      id: accidente.id,
      eventualidad: accidente.eventualidad, 
      proyecto: accidente.proyecto, 
      contratista: accidente.contratista, 
      mes: accidente.mes, 
      descripcion: accidente.descripcion, 
      diasIncapacidad: accidente.diasIncapacidad, 
      avances: accidente.avances, 
      estado: accidente.estado, 
      fechaRegistro: accidente.fechaRegistro, 
      usuarioId: accidente.usuarioId
    );
    return await localDatasource.actualizarAccidente(model);
    } catch (e) {
      throw Exception('Error al actualizar accidente: $e');
    }
    
  }

  @override
  Future<int> eliminarAccidente(int id) async {
    try {
      return await localDatasource.eliminarAccidente(id);
    } catch (e) {
      throw Exception('Error al eliminar accidente: $e');
    }
    
  }
}
