import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';

class EliminarNotificacionesUsecases {
  final NotificationRepository repository;

  EliminarNotificacionesUsecases(this.repository);

  Future<void> call() async {
    return await repository.eliminarTodas();
  }
}
