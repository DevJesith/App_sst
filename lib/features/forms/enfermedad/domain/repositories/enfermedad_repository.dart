
import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';

abstract class EnfermedadRepository {
  Future<List<Enfermedad>> getEnfermedad();
  Future<Enfermedad?> getEnfermedadById(int id);
  Future<List<Enfermedad>> getEnfermedadByUsuario(int usuarioId);
  Future<int> crearEnfermedad(Enfermedad enfermedad);
  Future<int> actualizarEnfermedad(Enfermedad enfermedad);
  Future<int> eliminarEnfermedad(int id);
  Future<List<Map<String, dynamic>>> getProyectos();
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectoId);
  Future<List<Map<String, dynamic>>> getTrabajadoresPorContratista(int proyectoId, int contratistaId);
}