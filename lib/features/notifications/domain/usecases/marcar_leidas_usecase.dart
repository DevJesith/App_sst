import 'package:app_sst/features/notifications/domain/repositories/notification_repository.dart';

class MarcarLeidasUsecase {
  final NotificationRepository repository;

  MarcarLeidasUsecase(this.repository);

  Future<void> call() async {
    return await repository.marcarTodasComoLeidas();
  }
}
