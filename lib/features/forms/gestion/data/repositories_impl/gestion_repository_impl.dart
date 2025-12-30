import 'package:app_sst/features/forms/gestion/data/datasources/gestion_local_datasources.dart';
import 'package:app_sst/features/forms/gestion/data/model/gestion_model.dart';
import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';

/// Implementacion del repositorio de gesion de inspeccion
/// 
/// Actua como intermediario entre la capa de Dominio (Casos de uso) y la capa de Datos (DataSource).
class GestionRepositoryImpl implements GestionRepository {
  final GestionLocalDatasources localDatasources;

  GestionRepositoryImpl({required this.localDatasources});

  @override
  Future<List<Gestion>> getGestiones() async {
    try {
      return await localDatasources.getGestion();
    } catch (e) {
      throw Exception('Error al obtener gestiones: $e');
    }
  }

  @override
  Future<Gestion?> getGestionById(int id) async {
    try {
      return await localDatasources.getGestionById(id);
    } catch (e) {
      throw Exception('Error al obtener gestion por id: $e');
    }
  }

  @override
  Future<List<Gestion>> getGestionesByUsuario(int usuarioId) async {
    try {
      return await localDatasources.getGestionesByUsuario(usuarioId);
    } catch (e) {
      throw Exception('Error al obtener gestiones del usuario: $e');
    }
  }

  @override
  Future<int> crearGestion(Gestion gestion) async {
    try {
      final model = GestionModel(
      ee: gestion.ee, 
      proyectoId: gestion.proyectoId, 
      epp: gestion.epp, 
      locativa: gestion.locativa, 
      extintorMaquina: gestion.extintorMaquina, 
      rutinariaMaquina: gestion.rutinariaMaquina, 
      gestionCumple: gestion.gestionCumple, 
      foto1: gestion.foto1, 
      foto2: gestion.foto2, 
      foto3: gestion.foto3, 
      fechaRegistro: gestion.fechaRegistro, 
      sincronizado: gestion.sincronizado,
      usuarioId: gestion.usuarioId
      );
      return await localDatasources.crearGestion(model);
    } catch (e) {
      throw Exception('Error al crear gestion: $e');
    }
  }

  @override
  Future<int> actualizarGestion(Gestion gestion) async {
    try {
      final model = GestionModel(
      id: gestion.id,
      ee: gestion.ee, 
      proyectoId: gestion.proyectoId, 
      epp: gestion.epp, 
      locativa: gestion.locativa, 
      extintorMaquina: gestion.extintorMaquina, 
      rutinariaMaquina: gestion.rutinariaMaquina, 
      gestionCumple: gestion.gestionCumple, 
      foto1: gestion.foto1, 
      foto2: gestion.foto2, 
      foto3: gestion.foto3, 
      fechaRegistro: gestion.fechaRegistro, 
      sincronizado: gestion.sincronizado,
      usuarioId: gestion.usuarioId
      );
      return await localDatasources.actualizarGestion(model);
    } catch (e) {
      throw Exception('Error al actualizar gestion: $e');
    }
  }

  @override
  Future<int> eliminarGestion(int id) async {
    try {
      return await localDatasources.eliminarGestion(id);
    } catch (e) {
      throw Exception('Error al eliminar gestion: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProyectos() async {
    return await localDatasources.getProyectos();
    
  }
}