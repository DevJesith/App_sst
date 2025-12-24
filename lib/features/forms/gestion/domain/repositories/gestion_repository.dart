

import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';

abstract class GestionRepository {
  Future<List<Gestion>> getGestiones();
  Future<Gestion?> getGestionById(int id);
  Future<List<Gestion>> getGestionesByUsuario(int usuarioId);
  Future<int> crearGestion(Gestion gestion);
  Future<int> actualizarGestion(Gestion gestion);
  Future<int> eliminarGestion(int id);
  Future<List<Map<String, dynamic>>> getProyectos();
}