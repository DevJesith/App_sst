import 'package:app_sst/data/database/app_database.dart';
import 'package:app_sst/features/forms/incidente/data/datasources/incidente_local_datasource.dart';
import 'package:app_sst/features/forms/incidente/data/repositories_impl/incidente_repository_impl.dart';
import 'package:app_sst/features/forms/incidente/domain/repositories/incidente_repository.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/actualizar_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/crear_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/eliminar_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/get_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/get_maestros_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/presentation/notifiers/incidente_notifier.dart';
import 'package:app_sst/features/forms/incidente/presentation/states/incidente_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

//Provider de DataSource
final incidenteLocalDataSourceProvider = Provider<IncidenteLocalDatasource>((
  ref,
) {
  final database = ref.watch(databaseProvider);
  return IncidenteLocalDatasourceImpl(database: database);
});

//Provider de Repositorio
final incidenteRepositoryProvider = Provider<IncidenteRepository>((ref) {
  final localDataSource = ref.watch(incidenteLocalDataSourceProvider);
  return IncidenteRepositoryImpl(localDatasource: localDataSource);
});

//Providers de Use Cases
final getIncidenteUseCaseProvider = Provider<GetIncidenteUsecases>((ref) {
  final repository = ref.watch(incidenteRepositoryProvider);
  return GetIncidenteUsecases(repository);
});

final crearIncidenteUseCaseProvider = Provider<CrearIncidenteUsecases>((ref) {
  final repository = ref.watch(incidenteRepositoryProvider);
  return CrearIncidenteUsecases(repository);
});

final actualizarIncidenteUseCaseProvider =
    Provider<ActualizarIncidenteUsecases>((ref) {
      final repository = ref.watch(incidenteRepositoryProvider);
      return ActualizarIncidenteUsecases(repository);
    });

final eliminarIncidenteUseCaseProvider = Provider<EliminarIncidenteUsecases>((
  ref,
) {
  final repository = ref.watch(incidenteRepositoryProvider);
  return EliminarIncidenteUsecases(repository);
});

final getProyectosIncidenteUseCaseProvider = Provider<GetProyectosIncidenteUseCase>((ref) {
  final repo = ref.watch(incidenteRepositoryProvider);
  return GetProyectosIncidenteUseCase(repo);
});

//Provider del Notifier principal (lista y CRUD)
final incidenteNotifierProvider =
    StateNotifierProvider<IncidenteNotifier, IncidenteState>((ref) {
      return IncidenteNotifier(
        getIncidenteUsecases: ref.watch(getIncidenteUseCaseProvider),
        crearIncidenteUsecases: ref.watch(crearIncidenteUseCaseProvider),
        actualizarIncidenteUsecases: ref.watch(
          actualizarIncidenteUseCaseProvider,
        ),
        eliminarIncidenteUsecases: ref.watch(eliminarIncidenteUseCaseProvider),
      );
    });

//Provider del Notifier del formulario (valores de campos)
final incidenteFormNotifierProvider =
    StateNotifierProvider.autoDispose<IncidenteFormNotifier, IncidenteFormState>((ref) {
      return IncidenteFormNotifier(
        getProyectosUseCase: ref.watch(getProyectosIncidenteUseCaseProvider),
      );
    });

//Providers derivados (para acceso directo a partes del estado)
final incidenteListProvider = Provider((ref) {
  return ref.watch(incidenteNotifierProvider).incidentes;
});

final incidenteLoadingProvider = Provider((ref) {
  return ref.watch(incidenteNotifierProvider).isLoading;
});

final incidentesErrorProvider = Provider((ref) {
  return ref.watch(incidenteNotifierProvider).errorMessage;
});

final incidentesSubmittingProvider = Provider((ref) {
  return ref.watch(incidenteNotifierProvider).isSubmitting;
});
