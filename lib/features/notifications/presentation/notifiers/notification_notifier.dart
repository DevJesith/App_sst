import 'package:app_sst/features/notifications/domain/entities/notification.dart';
import 'package:app_sst/features/notifications/domain/usecases/eliminar_notificaciones_usecases.dart';
import 'package:app_sst/features/notifications/domain/usecases/get_notificaciones_usecases.dart';
import 'package:app_sst/features/notifications/domain/usecases/guardar_noticaciones_usecase.dart';
import 'package:app_sst/features/notifications/domain/usecases/marcar_leidas_usecase.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NotificationNotifier extends StateNotifier<List<Notifications>> {
  final GetNotificacionesUsecases getNotificaciones;
  final GuardarNoticacionesUsecase guardarNotificacion;
  final MarcarLeidasUsecase marcarLeidas;
  final EliminarNotificacionesUsecases eliminarNotificaciones;

  NotificationNotifier({
    required this.getNotificaciones,
    required this.guardarNotificacion,
    required this.marcarLeidas,
    required this.eliminarNotificaciones,
  }) : super([]) {
    cargar();
  }

  Future<void> cargar() async {
    // Usamos el caso de uso
    state = await getNotificaciones();
  }

  Future<void> agregar(String titulo, String cuerpo) async {
    final nueva = Notifications(
      titulo: titulo,
      cuerpo: cuerpo,
      fecha: DateTime.now(),
    );
    await guardarNotificacion(nueva);
    await cargar();
  }

  Future<void> marcarComoLeidas() async {
    await marcarLeidas();
    await cargar();
  }

  Future<void> limpiar() async {
    await eliminarNotificaciones();
    state = [];
  }
}
