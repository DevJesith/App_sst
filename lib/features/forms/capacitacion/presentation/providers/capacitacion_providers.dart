// features/forms/capacitacion/presentation/providers/capacitacion_providers.dart

import 'package:app_sst/data/database/app_database.dart';
import 'package:app_sst/features/forms/capacitacion/data/datasources/capacitacion_local_datasources.dart';
import 'package:app_sst/features/forms/capacitacion/domain/repositories/capacitacion_repository.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/actualizar_capacitacion_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/create_capacitacion_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/eliminar_capacitacion_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/get_capacitaciones_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/get_maestros_capacitacion_usecases.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/repositories_impl/capacitacion_repository_impl.dart';

import '../notifiers/capacitacion_notifier.dart';
import '../states/capacitacion_state.dart';

// Provider de Database
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Provider de DataSource
final capacitacionLocalDataSourceProvider = Provider<CapacitacionLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return CapacitacionLocalDataSourceImpl(database: database);
});

// Provider de Repository
final capacitacionRepositoryProvider = Provider<CapacitacionRepository>((ref) {
  final localDataSource = ref.watch(capacitacionLocalDataSourceProvider);
  return CapacitacionRepositoryImpl(localDataSource: localDataSource);
});

// Providers de Use Cases
final getCapacitacionesUseCaseProvider = Provider<GetCapacitacionesUsecases>((ref) {
  final repository = ref.watch(capacitacionRepositoryProvider);
  return GetCapacitacionesUsecases(repository);
});

final createCapacitacionUseCaseProvider = Provider<CreateCapacitacionUsecases>((ref) {
  final repository = ref.watch(capacitacionRepositoryProvider);
  return CreateCapacitacionUsecases(repository);
});

final updateCapacitacionUseCaseProvider = Provider<ActualizarCapacitacionUsecases>((ref) {
  final repository = ref.watch(capacitacionRepositoryProvider);
  return ActualizarCapacitacionUsecases(repository);
});

final deleteCapacitacionUseCaseProvider = Provider<EliminarCapacitacionUsecases>((ref) {
  final repository = ref.watch(capacitacionRepositoryProvider);
  return EliminarCapacitacionUsecases(repository);
});

final getProyectosCapacitacionUseCaseProvider = Provider<GetProyectosCapacitacionUseCase>((ref) {
  final repo = ref.watch(capacitacionRepositoryProvider);
  return GetProyectosCapacitacionUseCase(repo);
});

final getContratistasCapacitacionUseCaseProvider = Provider<GetContratistasCapacitacionUseCase>((ref) {
  final repo = ref.watch(capacitacionRepositoryProvider);
  return GetContratistasCapacitacionUseCase(repo);
});

// Provider del Notifier principal
final capacitacionNotifierProvider = StateNotifierProvider<CapacitacionNotifier, CapacitacionState>((ref) {
  return CapacitacionNotifier(
    getCapacitacionesUseCase: ref.watch(getCapacitacionesUseCaseProvider),
    createCapacitacionUseCase: ref.watch(createCapacitacionUseCaseProvider),
    actualizarCapacitacionUseCase: ref.watch(updateCapacitacionUseCaseProvider),
    eliminarCapacitacionUseCase: ref.watch(deleteCapacitacionUseCaseProvider),
  );
});

// Provider del Notifier del formulario
final capacitacionFormNotifierProvider = StateNotifierProvider<CapacitacionFormNotifier, CapacitacionFormState>((ref) {
  return CapacitacionFormNotifier(
    getProyectosUseCase: ref.watch(getProyectosCapacitacionUseCaseProvider),
    getContratistasUseCase: ref.watch(getContratistasCapacitacionUseCaseProvider),
  );
});

// Providers derivados
final capacitacionesListProvider = Provider((ref) {
  return ref.watch(capacitacionNotifierProvider).capacitaciones;
});

final capacitacionesLoadingProvider = Provider((ref) {
  return ref.watch(capacitacionNotifierProvider).isLoading;
});

final capacitacionesErrorProvider = Provider((ref) {
  return ref.watch(capacitacionNotifierProvider).errorMessage;
});

final capacitacionesSubmittingProvider = Provider((ref) {
  return ref.watch(capacitacionNotifierProvider).isSubmitting;
});