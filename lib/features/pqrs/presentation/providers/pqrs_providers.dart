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

final PqrsLocalDatasourceProvider = Provider(
  (ref) => PqrsLocalDatasource(database: AppDatabase()),
);
final PqrsRepositoryProvider = Provider<PqrsRepository>(
  (ref) => PqrsRepositoryImpl(
    localDatasource: ref.watch(PqrsLocalDatasourceProvider),
  ),
);

// UseCases
final crearPqrsUseCaseProvider = Provider(
  (ref) => CrearPqrsUsecases(ref.watch(PqrsRepositoryProvider)),
);

final obtenerPqrsUseCaseProvider = Provider(
  (ref) => GetPqrsUsecase(ref.watch(PqrsRepositoryProvider)),
);

final resolverPqrsUseCaseProvider = Provider(
  (ref) => ResolverPqrsUsecases(ref.watch(PqrsRepositoryProvider)),
);

// Notifier
final pqrsNotifierProvider = StateNotifierProvider<PqrsNotifiers, List<Pqrs>>((
  ref,
) {
  return PqrsNotifiers(
    crearPqrs: ref.watch(crearPqrsUseCaseProvider),
    obtenerPqrs: ref.watch(obtenerPqrsUseCaseProvider),
    resolverPqrs: ref.watch(resolverPqrsUseCaseProvider),
  );
});
