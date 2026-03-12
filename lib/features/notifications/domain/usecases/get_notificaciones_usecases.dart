import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';
import 'package:app_sst/features/notifications/domain/entities/notification.dart';

/// Caso de uso encargado de recuperar la lista de notificaciones.
/// 
/// Interviene entre la capa de presentacion y el repositorio de datos,
/// encapsulando la logica para obtener el listado actual de notificaciones
/// disponibles para el usuario.
class GetNotificacionesUsecases {
  /// Repositorio inyectado que maneja las operaciones de datos.
  final NotificationRepository repository;

  GetNotificacionesUsecases(this.repository);

  /// Ejecuta el caso de uso y retorna una lista de [Notifications].
  Future<List<Notifications>> call() async {
    return await repository.obtenerNotifaciones();
  }
}
