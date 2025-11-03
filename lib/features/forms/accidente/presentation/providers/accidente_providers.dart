import 'package:app_sst/data/database/app_database.dart';
import 'package:app_sst/features/auth/domain/usecases/actualizar_usuario.dart';
import 'package:app_sst/features/forms/accidente/data/datasources/accidente_local_datasource.dart';
import 'package:app_sst/features/forms/accidente/data/repositories_impl/accidente_repository_impl.dart';
import 'package:app_sst/features/forms/accidente/domain/repositories/accidente_repository.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/actualizar_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/crear_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/eliminar_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/get_accidentes_usecases.dart';
import 'package:app_sst/features/forms/accidente/presentation/notifiers/accidente_notifier.dart';
import 'package:app_sst/features/forms/accidente/presentation/states/accidente_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

//Provider de DataSource
final accidenteLocaDataSourceProvider = Provider<AccidenteLocalDatasource>((
  ref,
) {
  final database = ref.watch(databaseProvider);
  return AccidenteLocalDataSourceImpl(database: database);
});

//Provider de Repositort
final accidenteRepositoryProvider = Provider<AccidenteRepository>((ref) {
  final localDataSource = ref.watch(accidenteLocaDataSourceProvider);
  return AccidenteRepositoryImpl(localDatasource: localDataSource);
});

//Providers de Use Cases
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

//Provider del Notifier princiapl (lista y CRUD)
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

//Provider del Notifier del formulario (valores de campos)
final accidenteFormNotifierProvider = StateNotifierProvider<AccidenteFormNotifier, AccidenteFormState>((ref) {
  return AccidenteFormNotifier();
});

// Providers derivados (para acceso directo a partes del estado)
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

