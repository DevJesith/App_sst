
import 'package:app_sst/data/database/app_database.dart';
import 'package:app_sst/features/forms/gestion/data/datasources/gestion_local_datasources.dart';
import 'package:app_sst/features/forms/gestion/data/repositories_impl/gestion_repository_impl.dart';
import 'package:app_sst/features/forms/gestion/domain/repositories/gestion_repository.dart';
import 'package:app_sst/features/forms/gestion/domain/usecases/actualizar_gestion_usecases.dart';
import 'package:app_sst/features/forms/gestion/domain/usecases/crear_gestion_usecases.dart';
import 'package:app_sst/features/forms/gestion/domain/usecases/eliminar_gestion_usecases.dart';
import 'package:app_sst/features/forms/gestion/domain/usecases/get_gestion_usecases.dart';
import 'package:app_sst/features/forms/gestion/presentation/notifiers/gestion_notifier.dart';
import 'package:app_sst/features/forms/gestion/presentation/states/gestion_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final gestionLocalDataBaseSourceProvider = Provider<GestionLocalDatasources>((ref) {
  final database = ref.watch(databaseProvider);
  return GestionLocalDataSourceImpl(database: database);
});

final gestionRepositoryProvider = Provider<GestionRepository>((ref) {
  final localDataSource = ref.watch(gestionLocalDataBaseSourceProvider);
  return GestionRepositoryImpl(localDatasources: localDataSource);
});

//Providers de Use Cases
final getGestionesUseCaseProvider = Provider<GetGestionUsecases>((ref) {
  final repository = ref.watch(gestionRepositoryProvider);
  return GetGestionUsecases(repository);
});

final crearGestionUseCaseProvider = Provider<CrearGestionUsecases>((ref) {
  final repository = ref.watch(gestionRepositoryProvider);
  return CrearGestionUsecases(repository);
});

final actualizarGestionUseCaseProvider = Provider<ActualizarGestionUsecases>((ref) {
  final repository = ref.watch(gestionRepositoryProvider);
  return ActualizarGestionUsecases(repository);
});

final eliminarGestionUseCaseProvider = Provider<EliminarGestionUsecases>((ref) {
  final repository = ref.watch(gestionRepositoryProvider);
  return EliminarGestionUsecases(repository);
});

//Provider del Notifier principal
final gestionNotifierProvider = StateNotifierProvider<GestionNotifier, GestionState>((ref) {
  return GestionNotifier(
  getGestionUsecases: ref.watch(getGestionesUseCaseProvider), 
  crearGestionUsecases: ref.watch(crearGestionUseCaseProvider), 
  actualizarGestionUsecases: ref.watch(actualizarGestionUseCaseProvider), 
  eliminarGestionUsecases: ref.watch(eliminarGestionUseCaseProvider)
  );
});

//Provider del Notifier principal del formulario

final gestionFormNotifierProvider = StateNotifierProvider<GestionFormNotifier, GestionFormState>((ref) {
  return GestionFormNotifier();
});

//Providers derivados
final gestionesListProvider = Provider((ref) {
  return ref.watch(gestionNotifierProvider).gestiones;
});

final gestionesLoadingProvider = Provider((ref) {
  return ref.watch(gestionNotifierProvider).isLoading;
});

final gestionesErrorProvider = Provider((ref) {
  return ref.watch(gestionNotifierProvider).errorMessage;
});

final gestionesSubmittingProvider = Provider((ref) {
  return ref.watch(gestionNotifierProvider).isSubmitting;
});