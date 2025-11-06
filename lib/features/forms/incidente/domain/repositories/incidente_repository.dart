

import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';

abstract class IncidenteRepository {
  Future<List<Incidente>> getIncidente();
  Future<Incidente?> getIncidenteById(int id);
  Future<List<Incidente>> getIncidenteByUsuario(int usuarioId);
  Future<int> crearIncidente(Incidente incidente);
  Future<int> actualizarIncidente(Incidente incidente);
  Future<int> eliminarIncidente(int id);
}