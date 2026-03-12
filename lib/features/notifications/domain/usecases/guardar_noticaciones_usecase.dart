import 'package:app_sst/features/notifications/domain/entities/notification.dart';
import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';

/// Caso de uso encargado de almacenar una nueva notificacion.
/// 
/// Interviene entre la capa de presentacion/servicios externos y el repositorio,
/// encapsulando la logica requerida para persistir una notificacion en el origen de datos.
class GuardarNoticacionesUsecase {
  /// Repositorio inyectado que maneja las operaciones de datos.
  final NotificationRepository repository;

  GuardarNoticacionesUsecase(this.repository);

  /// Ejecuta el caso de uso guardando la [notificacion] proporcionada.
  Future<void> call(Notifications notificacion) async {
    return await repository.guardarNotificacion(notificacion);
  }
}
