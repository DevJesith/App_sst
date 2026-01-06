import 'package:app_sst/core/data/database/app_database.dart';
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

// -------------------------------------------------------------------------------------------
// 1. CAPA DE DATOS
// -------------------------------------------------------------------------------------------

/// Provider de la base de datos local.
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider del DataSource Local. 
final incidenteLocalDataSourceProvider = Provider<IncidenteLocalDatasource>((
  ref,
) {
  final database = ref.watch(databaseProvider);
  return IncidenteLocalDatasourceImpl(database: database);
});

//Provider de Repositorio.
final incidenteRepositoryProvider = Provider<IncidenteRepository>((ref) {
  final localDataSource = ref.watch(incidenteLocalDataSourceProvider);
  return IncidenteRepositoryImpl(localDatasource: localDataSource);
});

// -------------------------------------------------------------------------------------------
// 2. CAPA DE DOMINIO (CASOS DE USO)
// -------------------------------------------------------------------------------------------

// --- CRUD ---
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

// -------------------------------------------------------------------------------------------
// 3. CAPA DE PRESENTACION
// -------------------------------------------------------------------------------------------

/// Provider del Notifier principal (Lista de Incidentes y CRUD).
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

//Provider del Notifier del formulario.
final incidenteFormNotifierProvider =
    StateNotifierProvider.autoDispose<IncidenteFormNotifier, IncidenteFormState>((ref) {
      return IncidenteFormNotifier(
        getProyectosUseCase: ref.watch(getProyectosIncidenteUseCaseProvider),
      );
    });

// -------------------------------------------------------------------------------------------
// 4. SELECTORS
// -------------------------------------------------------------------------------------------

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
