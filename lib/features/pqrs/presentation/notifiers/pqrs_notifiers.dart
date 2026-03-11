import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';
import 'package:app_sst/features/pqrs/domain/usecases/crear_pqrs_usecases.dart';
import 'package:app_sst/features/pqrs/domain/usecases/get_pqrs_usecase.dart';
import 'package:app_sst/features/pqrs/domain/usecases/resolver_pqrs_usecases.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PqrsNotifiers extends StateNotifier<List<Pqrs>> {
  final CrearPqrsUsecases crearPqrs;
  final GetPqrsUsecase obtenerPqrs;
  final ResolverPqrsUsecases resolverPqrs;

  PqrsNotifiers({
    required this.crearPqrs,
    required this.obtenerPqrs,
    required this.resolverPqrs,
  }) : super([]) {
    cargarTodos();
  }

  Future<void> cargarTodos() async {
    state = await obtenerPqrs();
  }

  Future<void> enviarNueva(Pqrs pqrs) async {
    await crearPqrs(pqrs);
    await cargarTodos();
  }

  Future<void> resolver(int id) async {
    await resolverPqrs(id);
    await cargarTodos();
  }
}
