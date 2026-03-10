// 1. DataSource
import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:app_sst/features/notifications/data/repositories_impl/notification_repository_impl.dart';
import 'package:app_sst/features/notifications/domain/entities/notification.dart';
import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';
import 'package:app_sst/features/notifications/domain/usecases/eliminar_notificaciones_usecases.dart';
import 'package:app_sst/features/notifications/domain/usecases/get_notificaciones_usecases.dart';
import 'package:app_sst/features/notifications/domain/usecases/guardar_noticaciones_usecase.dart';
import 'package:app_sst/features/notifications/domain/usecases/marcar_leidas_usecase.dart';
import 'package:app_sst/features/notifications/presentation/notifiers/notification_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final notificationLocalDataSourceProvider =
    Provider<NotificationLocalDatasource>((ref) {
      return NotificationLocalDatasource(database: AppDatabase());
    });

// 2. Repository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    localDatasource: ref.watch(notificationLocalDataSourceProvider),
  );
});

// 3. USECASES
final getNotificacionesUseCaseProvider = Provider((ref) {
  return GetNotificacionesUsecases(ref.watch(notificationRepositoryProvider));
});

final guardarNotificacionUseCaseProvider = Provider((ref) {
  return GuardarNoticacionesUsecase(ref.watch(notificationRepositoryProvider));
});

final marcarLeidasUseCaseProvider = Provider((ref) {
  return MarcarLeidasUsecase(ref.watch(notificationRepositoryProvider));
});

final eliminarNotificacionesUseCaseProvider = Provider((ref) {
  return EliminarNotificacionesUsecases(
    ref.watch(notificationRepositoryProvider),
  );
});

// 4. Notifier
final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, List<Notifications>>((ref) {
      return NotificationNotifier(
        getNotificaciones: ref.watch(getNotificacionesUseCaseProvider),
        guardarNotificacion: ref.watch(guardarNotificacionUseCaseProvider),
        marcarLeidas: ref.watch(marcarLeidasUseCaseProvider),
        eliminarNotificaciones: ref.watch(
          eliminarNotificacionesUseCaseProvider,
        ),
      );
    });
