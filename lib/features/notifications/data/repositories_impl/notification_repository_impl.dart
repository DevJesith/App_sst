import 'package:app_sst/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:app_sst/features/notifications/domain/entities/notification.dart';
import '../models/notification_model.dart';
import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';

/// Implementación concreta del [NotificationRepository].
/// 
/// Actua como la capa central de orquestacion de datos: recibe peticiones 
/// desde los Casos de Uso (dominio) y las dirige hacia la fuente de datos 
/// local (SQLite) a través del [NotificationLocalDatasource].
class NotificationRepositoryImpl implements NotificationRepository {
  /// Dependencia hacia la fuente de datos local.
  final NotificationLocalDatasource localDatasource;

  NotificationRepositoryImpl({required this.localDatasource});

  /// Recupera todas las notificaciones desde la base de datos local.
  @override
  Future<List<Notifications>> obtenerNotifaciones() async {
    return await localDatasource.getNotificaciones();
  }

  /// Convierte una entidad de dominio ([Notifications]) en un modelo de 
  /// base de datos ([NotificationModel]) y la guarda localmente.
  @override
  Future<void> guardarNotificacion(Notifications notificacion) async {
    final model = NotificationModel(
      titulo: notificacion.titulo,
      cuerpo: notificacion.cuerpo,
      fecha: notificacion.fecha,
      leido: notificacion.leido,
      usuariosId: notificacion.usuariosId,
    );
    await localDatasource.guardarNotificacion(model);
  }

  /// Delega la actualizacion masiva para marcar todas las notificaciones
  /// como leidas en la fuente de datos local.
  @override
  Future<void> marcarTodasComoLeidas() async {
    await localDatasource.marcarTodasComoLeidas();
  }

  /// Elimina todo el historial de notificaciones.
  @override
  Future<void> eliminarTodas() async {
    await localDatasource.eliminarTodas();
  }
}
