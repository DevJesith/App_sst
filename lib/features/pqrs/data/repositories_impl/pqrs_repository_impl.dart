import 'package:app_sst/features/pqrs/data/datasources/pqrs_local_datasource.dart';
import 'package:app_sst/features/pqrs/data/models/pqrs_model.dart';
import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';
import 'package:app_sst/features/pqrs/domain/repositories/pqrs_repository.dart';

class PqrsRepositoryImpl implements PqrsRepository {
  final PqrsLocalDatasource localDatasource;

  PqrsRepositoryImpl({required this.localDatasource});

  @override
  Future<void> crearPqrs(Pqrs pqrs) async {
    final model = PqrsModel(
      tipo: pqrs.tipo,
      nombreSolicitante: pqrs.nombreSolicitante,
      correoContacto: pqrs.correoContacto,
      descripcion: pqrs.descripcion,
      fechaCreacion: pqrs.fechaCreacion,
      estado: pqrs.estado,
    );
    await localDatasource.insertPqrs(model);
  }

  @override
  Future<List<Pqrs>> obtenerTodos() async {
    return await localDatasource.getPqrs();
  }

  @override
  Future<void> marcarComoResuelto(int id) async {
    await localDatasource.resolverPqrs(id);
  }
}
