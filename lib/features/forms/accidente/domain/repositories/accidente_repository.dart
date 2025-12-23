
import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';

abstract class AccidenteRepository {
  Future<List<Accidente>> getAccidentes();
  Future<Accidente?> getAccidenteById(int id);
  Future<List<Accidente>> getAccidenteByUsuario(int usuarioId);
  Future<int> crearAccidente(Accidente accidente);
  Future<int> actualizarAccidente(Accidente accidente);
  Future<int> eliminarAccidente(int id);
  Future<List<Map<String, dynamic>>> getProyectos();
  Future<List<Map<String, dynamic>>> getContratistasPorProyectos(int proyectoId);
}