import 'package:app_sst/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:app_sst/features/notifications/domain/entities/notification.dart';
import '../models/notification_model.dart';
import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDatasource localDatasource;

  NotificationRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Notifications>> obtenerNotifaciones() async {
    return await localDatasource.getNotificaciones();
  }

  @override
  Future<void> guardarNotificacion(Notifications notificacion) async {
    final model = NotificationModel(
      titulo: notificacion.titulo,
      cuerpo: notificacion.cuerpo,
      fecha: notificacion.fecha,
      leido: notificacion.leido,
    );
    await localDatasource.insertNotificacion(model);
  }

  @override
  Future<void> marcarTodasComoLeidas() async {
    await localDatasource.markAllAsRead();
  }

  @override
  Future<void> eliminarTodas() async {
    await localDatasource.deleteAll();
  }
}
