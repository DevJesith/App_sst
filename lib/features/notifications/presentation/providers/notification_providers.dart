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

/// ==========================================
/// 1. DATA SOURCE (Fuente de Datos)
/// ==========================================

/// Proveedor centralizado que provee la instancia unica de la base de datos SQLite.
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Proveedor del DataSource local especifico para notificaciones.
/// Se le inyecta la base de datos (`databaseProvider`) para poder realizar operaciones locales.
final notificacionLocalDataSourceProvider =
    Provider<NotificationLocalDatasource>((ref) {
      final database = ref.watch(databaseProvider);
      return NotificationLocalDataSourceImpl(database: database);
    });

/// ==========================================
/// 2. REPOSITORY (Repositorio)
/// ==========================================
/// Proveedor que implementa el contrato (interfaz) de notificaciones.
/// Se le inyecta (`ref.watch`) el DataSource local para que pueda interactuar con la DB.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final localDataSource = ref.watch(notificacionLocalDataSourceProvider);
  return NotificationRepositoryImpl(localDatasource: localDataSource);
});

/// ==========================================
/// 3. CASOS DE USO (UseCases)
/// ==========================================
/// Proveedores individuales para cada accion del dominio.
/// A todos se les inyecta el `notificationRepositoryProvider`.

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

/// ==========================================
/// 4. NOTIFIER / STATE (Estado de la UI)
/// ==========================================
/// Proveedor que maneja el estado reactivo (`StateNotifier`) para la interfaz de usuario.
/// Se encarga de exponer la lista actual de notificaciones y métodos para interactuar
/// con los casos de uso.
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
