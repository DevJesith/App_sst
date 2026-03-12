import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';

/// Caso de uso encargado de eliminar todas las notificaciones del sistema.
/// 
/// Interviene entre la capa de presentacion y el repositorio de datos,
/// encapsulando la logica especifica para borrar el historial de notificaciones.
class EliminarNotificacionesUsecases {
  /// Repositorio inyectado que maneja las operaciones de datos.
  final NotificationRepository repository;

  EliminarNotificacionesUsecases(this.repository);

  /// Ejecuta el caso de uso para eliminar todas las notificaciones.
  Future<void> call() async {
    return await repository.eliminarTodas();
  }
}
