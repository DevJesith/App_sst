import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';
import 'package:app_sst/features/notifications/domain/entities/notification.dart';

class GetNotificacionesUsecases {
  final NotificationRepository repository;

  GetNotificacionesUsecases(this.repository);

  Future<List<Notifications>> call() async {
    return await repository.obtenerNotifaciones();
  }
}
