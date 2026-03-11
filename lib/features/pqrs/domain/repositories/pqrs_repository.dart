import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';

abstract class PqrsRepository {
  Future<void> crearPqrs(Pqrs pqrs);
  Future<List<Pqrs>> obtenerTodos();
  Future<void> marcarComoResuelto(int id);
}
