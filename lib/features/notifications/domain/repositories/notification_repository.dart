import '../entities/notification.dart';

/// Interfaz (contrato) que define las operaciones disponibles para las notificaciones.
/// 
/// Actua como un puente entre la capa de dominio de la aplicacion y la 
/// fuente de los datos, ocultando los detalles de implementacion.
abstract class NotificationRepository {
  /// Obtiene la lista de todas las notificaciones disponibles en el sistema.
  Future<List<Notifications>> obtenerNotifaciones();

  /// Guarda una nueva [notificacion] en el repositorio de datos.
  Future<void> guardarNotificacion(Notifications notificacion);

  /// Actualiza el estado de todas las notificaciones marcandolas 
  /// como leidas (`leido` = true).
  Future<void> marcarTodasComoLeidas();

  /// Elimina por completo todas las notificaciones del sistema.
  Future<void> eliminarTodas();
}
