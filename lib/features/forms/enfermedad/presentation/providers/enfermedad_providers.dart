import 'package:app_sst/data/database/app_database.dart';
import 'package:app_sst/features/forms/enfermedad/data/datasources/enfermedad_local_datasource.dart';
import 'package:app_sst/features/forms/enfermedad/data/repositories_impl/enfermedad_repository_impl.dart';
import 'package:app_sst/features/forms/enfermedad/domain/repositories/enfermedad_repository.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/actualizar_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/crear_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/eliminar_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/get_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/get_maestros_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/presentation/notifiers/enfermedad_notifier.dart';
import 'package:app_sst/features/forms/enfermedad/presentation/states/enfermedad_states.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// -------------------------------------------------------------------------------------------
// 1. CAPA DE DATOS
// -------------------------------------------------------------------------------------------

/// Provider de la base de datos local.
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider del DataSource local.
final enfermedadLocalDataSourceProvider =
    Provider<EnfermedadLocalDataSourceImpl>((ref) {
      final database = ref.watch(databaseProvider);
      return EnfermedadLocalDataSourceImpl(database: database);
    });

/// Provider del Repositorio.
final enfermedadRepositoryProvider = Provider<EnfermedadRepository>((ref) {
  final localDataSource = ref.watch(enfermedadLocalDataSourceProvider);
  return EnfermedadRepositoryImpl(localDatasource: localDataSource);
});

// -------------------------------------------------------------------------------------------
// 2. CAPA DE DOMINIO (CASOS DE USO)
// -------------------------------------------------------------------------------------------

// --- CRUD ---
final getEnfermedadUseCaseProvider = Provider<GetEnfermedadUsecases>((ref) {
  final repository = ref.watch(enfermedadRepositoryProvider);
  return GetEnfermedadUsecases(repository);
});

final crearEnfermedadUseCaseProvider = Provider<CrearEnfermedadUsecases>((ref) {
  final repository = ref.watch(enfermedadRepositoryProvider);
  return CrearEnfermedadUsecases(repository);
});

final actualizarEnfermedadUseCaseProvider =
    Provider<ActualizarEnfermedadUsecases>((ref) {
      final repository = ref.watch(enfermedadRepositoryProvider);
      return ActualizarEnfermedadUsecases(repository);
    });

final eliminarEnfermedadUseCaseProvider = Provider<EliminarEnfermedadUsecases>((ref) {
  final repository = ref.watch(enfermedadRepositoryProvider);
  return EliminarEnfermedadUsecases(repository);
});

final getProyectosEnfermedadUseCaseProvider = Provider((ref) => GetProyectosEnfermedadUseCase(ref.watch(enfermedadRepositoryProvider)));

final getContratistasEnfermedadesUseCaseProvider = Provider((ref) => GetContratistasEnfermedadesUseCase(ref.watch(enfermedadRepositoryProvider)));

final getTrabajadoresEnfermedadUseCaseProvider = Provider((ref) => GetTrabajadoresEnfermedadUseCase(ref.watch(enfermedadRepositoryProvider)));

// -------------------------------------------------------------------------------------------
// 3. CAPA DE PRESENTACION
// -------------------------------------------------------------------------------------------

/// Provider del Notifier principal
final enfermedadNotifierProvider = StateNotifierProvider<EnfermedadNotifier, EnfermedadStates>((ref) {
  return EnfermedadNotifier(
  getEnfermedadUsecases: ref.watch(getEnfermedadUseCaseProvider), 
  crearEnfermedadUsecases: ref.watch(crearEnfermedadUseCaseProvider), 
  actualizarEnfermedadUsecases: ref.watch(actualizarEnfermedadUseCaseProvider), 
  eliminarEnfermedadUsecases: ref.watch(eliminarEnfermedadUseCaseProvider)
  );
});

//Provider del Notifier del formulario(valores de campos)
final enfermedadFormNotifierProvider = StateNotifierProvider<EnfermedadFormNotifier, EnfermedadFormState>((ref) {
  return EnfermedadFormNotifier(
    getProyectosUseCase: ref.watch(getProyectosEnfermedadUseCaseProvider),
    getContratistasUseCase: ref.watch(getContratistasEnfermedadesUseCaseProvider),
    getTrabajadoresUseCase: ref.watch(getTrabajadoresEnfermedadUseCaseProvider),

  );
});

// -------------------------------------------------------------------------------------------
// 4. SELECTORS
// -------------------------------------------------------------------------------------------

final enfermedadListProvider = Provider((ref) {
  return ref.watch(enfermedadNotifierProvider).enfermedad;
});

final enfermedadLoadingProvider = Provider((ref) {
  return ref.watch(enfermedadNotifierProvider).isLoading;
});

final enfermedadErrorProvider = Provider((ref) {
  return ref.watch(enfermedadNotifierProvider).errorMessage;
});

final enfermedadSubmittingProvider = Provider((ref) {
  return ref.watch(enfermedadNotifierProvider).isSubmitting;
});