import 'package:app_sst/features/notifications/domain/entities/notification.dart';
import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';

class GuardarNoticacionesUsecase {
  final NotificationRepository repository;

  GuardarNoticacionesUsecase(this.repository);

  Future<void> call(Notifications notificacion) async {
    return await repository.guardarNotificacion(notificacion);
  }
}
