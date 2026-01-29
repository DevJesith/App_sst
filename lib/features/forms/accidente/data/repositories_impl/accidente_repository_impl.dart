import '../../domain/entities/accidente.dart';
import '../../domain/repositories/accidente_repository.dart';
import '../datasources/accidente_local_datasource.dart';
import '../model/accidente_model.dart';

/// Implementacion del repositorio de Accidentes.
///
/// Actua como intermediario entre la capa de Dominio y la capa de datos (DataSource).
/// Se encarga de la conversion de datos  entre el model y entity y entre el manejo de errores
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
        proyectoId: accidente.proyectoId,
        contratistaId: accidente.contratistaId,
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
        proyectoId: accidente.proyectoId,
        contratistaId: accidente.contratistaId,
        descripcion: accidente.descripcion,
        diasIncapacidad: accidente.diasIncapacidad,
        avances: accidente.avances,
        estado: accidente.estado,
        fechaRegistro: accidente.fechaRegistro,
        usuarioId: accidente.usuarioId,
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

  @override
  Future<List<Map<String, dynamic>>> getProyectos() async {
    return await localDatasource.getProyectos();
  }

  @override
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(
    int proyectoId,
  ) async {
    return await localDatasource.getContratistasPorProyectos(proyectoId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllContratistas() async {
    return await localDatasource.getAllContratistas();
  }
}
