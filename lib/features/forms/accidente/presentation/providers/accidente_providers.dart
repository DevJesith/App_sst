import 'package:app_sst/data/database/app_database.dart';
import 'package:app_sst/features/forms/accidente/data/datasources/accidente_local_datasource.dart';
import 'package:app_sst/features/forms/accidente/data/repositories_impl/accidente_repository_impl.dart';
import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/actualizar_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/crear_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/eliminar_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/get_accidentes_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/get_maestros_usecases.dart';
import 'package:app_sst/features/forms/accidente/presentation/notifiers/accidente_notifier.dart';
import 'package:app_sst/features/forms/accidente/presentation/states/accidente_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ----------------------------------------------------------------------------------------
// 1. CAPA DE DATOS
// ----------------------------------------------------------------------------------------
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider de DataSource loca.
/// Se encarga de las consultas directas a SQLite
final accidenteLocaDataSourceProvider = Provider<AccidenteLocalDatasource>((
  ref,
) {
  final database = ref.watch(databaseProvider);
  return AccidenteLocalDataSourceImpl(database: database);
});

/// Provider de Repositorio.
/// Implementa la interfaz del dominio usando el DataSource local.
final accidenteRepositoryProvider = Provider<AccidenteRepository>((ref) {
  final localDataSource = ref.watch(accidenteLocaDataSourceProvider);
  return AccidenteRepositoryImpl(localDatasource: localDataSource);
});

// ----------------------------------------------------------------------------------------
// 2. CAPA DE DOMINIO (CASOS DE USO)
// ---------------------------------------------------------------------------------------

// --- CRUD ---
final getAccidenteUseCaseProvider = Provider<GetAccidentesUsecases>((ref) {
  final repository = ref.watch(accidenteRepositoryProvider);
  return GetAccidentesUsecases(repository);
});

final crearAccidenteUseCaseProvider = Provider<CrearAccidenteUsecases>((ref) {
  final repository = ref.watch(accidenteRepositoryProvider);
  return CrearAccidenteUsecases(repository);
});

final actualizarAccidenteUseCaseProvider =
    Provider<ActualizarAccidenteUsecases>((ref) {
      final repository = ref.watch(accidenteRepositoryProvider);
      return ActualizarAccidenteUsecases(repository);
    });

final eliminarAccidenteUseCaseProvider = Provider<EliminarAccidenteUsecases>((
  ref,
) {
  final repository = ref.watch(accidenteRepositoryProvider);
  return EliminarAccidenteUsecases(repository);
});

final getProyectosUseCaseProvider = Provider<GetProyectosUseCase>((ref) {
  final repo = ref.watch(accidenteRepositoryProvider);
  return GetProyectosUseCase(repo);
});

final getContratistasUseCaseProvider =
    Provider<GetContratistasPorProyectoUseCase>((ref) {
      final repo = ref.watch(accidenteRepositoryProvider);
      return GetContratistasPorProyectoUseCase(repo);
    });

// ----------------------------------------------------------------------------------------
// 3. CAPA DE PRESENTACION (STATE MANAGEMENT)
// ----------------------------------------------------------------------------------------

/// Provider del Notifier principal (Lista de Accidentes y operaciones CRUD).
final accidenteNotifierProvider =
    StateNotifierProvider<AccidenteNotifier, AccidenteState>((ref) {
      return AccidenteNotifier(
        getAccidentesUsecases: ref.watch(getAccidenteUseCaseProvider),
        crearAccidenteUsecases: ref.watch(crearAccidenteUseCaseProvider),
        actualizarAccidenteUsecases: ref.watch(
          actualizarAccidenteUseCaseProvider,
        ),
        eliminarAccidenteUsecases: ref.watch(eliminarAccidenteUseCaseProvider),
      );
    });

/// Provider del Notifier del formulario (Manejo de campos y dropdowns).
/// Usamos 'autoDispose' para limpiar el estado al salir de la pantalla.
final accidenteFormNotifierProvider =
    StateNotifierProvider<AccidenteFormNotifier, AccidenteFormState>((ref) {
      return AccidenteFormNotifier(
        getProyectosUseCase: ref.watch(getProyectosUseCaseProvider),
        getContratistasPorProyectoUseCase: ref.watch(
          getContratistasUseCaseProvider,
        ),
      );
    });


// ----------------------------------------------------------------------------------------
// 4. SELECTORS (ACCESO RAPIDO A VALORES)
// ----------------------------------------------------------------------------------------

final accidentesListProvider = Provider((ref) {
  return ref.watch(accidenteNotifierProvider).accidentes;
});

final accidentesLoadingProvider = Provider((ref) {
  return ref.watch(accidenteNotifierProvider).isLoading;
});

final accidentesErrorProvider = Provider((ref) {
  return ref.watch(accidenteNotifierProvider).errorMessage;
});

final accidentesSubmittingProvider = Provider((ref) {
  return ref.watch(accidenteNotifierProvider).isSubmitting;
});
