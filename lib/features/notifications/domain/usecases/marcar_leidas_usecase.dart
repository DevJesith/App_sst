import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';

/// Caso de uso encargado de actualizar el estado de las notificaciones a "leidas".
/// 
/// Interviene entre la capa de presentacion y el repositorio de datos,
/// permitiendo que el usuario marque todo su buzon de notificaciones como visto.
class MarcarLeidasUsecase {
  /// Repositorio inyectado que maneja las operaciones de datos.
  final NotificationRepository repository;

  MarcarLeidasUsecase(this.repository);

  /// Ejecuta el caso de uso para marcar todas las notificaciones como leidas.
  Future<void> call() async {
    return await repository.marcarTodasComoLeidas();
  }
}
