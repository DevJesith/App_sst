import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<Notifications>> obtenerNotifaciones();
  Future<void> guardarNotificacion(Notifications notificacion);
  Future<void> marcarTodasComoLeidas();
  Future<void> eliminarTodas();
}
