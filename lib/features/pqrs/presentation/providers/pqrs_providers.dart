import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/pqrs/data/datasources/pqrs_local_datasource.dart';
import 'package:app_sst/features/pqrs/data/repositories_impl/pqrs_repository_impl.dart';
import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';
import 'package:app_sst/features/pqrs/domain/repositories/pqrs_repository.dart';
import 'package:app_sst/features/pqrs/domain/usecases/crear_pqrs_usecases.dart';
import 'package:app_sst/features/pqrs/domain/usecases/get_pqrs_usecase.dart';
import 'package:app_sst/features/pqrs/domain/usecases/resolver_pqrs_usecases.dart';
import 'package:app_sst/features/pqrs/presentation/notifiers/pqrs_notifiers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ----------------------------------------------------------------------------------------
// 1. CAPA DE DATOS
// ----------------------------------------------------------------------------------------

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider de DataSourceLocal
/// Se encarga de las consultas directas a SQLite
final pqrsLocalDataSourceProvider = Provider<PqrsLocalDatasource>((ref) {
  final database = ref.watch(databaseProvider);
  return PqrsLocalDataSourceImpl(database: database);
});

/// Provider de Repositorio
/// Implementa la interfaz del dominio usando el DataSourceLocal
final pqrsRepositoryProvider = Provider<PqrsRepository>((ref) {
  final localDataSource = ref.watch(pqrsLocalDataSourceProvider);
  return PqrsRepositoryImpl(localDatasource: localDataSource);
});

// ----------------------------------------------------------------------------------------
// 2. CAPA DE DOMINIO (CASOS DE USO)
// ---------------------------------------------------------------------------------------

final crearPqrsUseCaseProvider = Provider(
  (ref) => CrearPqrsUsecases(ref.watch(pqrsRepositoryProvider)),
);

final obtenerPqrsUseCaseProvider = Provider(
  (ref) => GetPqrsUsecase(ref.watch(pqrsRepositoryProvider)),
);

final resolverPqrsUseCaseProvider = Provider(
  (ref) => ResolverPqrsUsecases(ref.watch(pqrsRepositoryProvider)),
);

// ----------------------------------------------------------------------------------------
// 3. CAPA DE PRESENTACION (STATE MANAGEMENT)
// ----------------------------------------------------------------------------------------

final pqrsNotifierProvider = StateNotifierProvider<PqrsNotifiers, List<Pqrs>>((
  ref,
) {
  return PqrsNotifiers(
    crearPqrs: ref.watch(crearPqrsUseCaseProvider),
    obtenerPqrs: ref.watch(obtenerPqrsUseCaseProvider),
    resolverPqrs: ref.watch(resolverPqrsUseCaseProvider),
  );
});
