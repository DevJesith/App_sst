import 'package:app_sst/features/notifications/domain/entities/notification.dart';
import 'package:app_sst/features/notifications/domain/usecases/eliminar_notificaciones_usecases.dart';
import 'package:app_sst/features/notifications/domain/usecases/get_notificaciones_usecases.dart';
import 'package:app_sst/features/notifications/domain/usecases/guardar_noticaciones_usecase.dart';
import 'package:app_sst/features/notifications/domain/usecases/marcar_leidas_usecase.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app_sst/services/storage_service.dart';

/// Notifier que administra y provee el estado (lista) de las [Notifications] a la UI.
/// 
/// Utiliza **Riverpod** (`StateNotifier`) para mantener el listado actualizado.
/// Interacciona directamente con los Casos de Uso (dominio) para realizar
/// operaciones y luego refrescar el estado visible en la aplicacion.
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
    // Carga las notificaciones existentes desde la base de datos al inicializarse.
    cargar();
  }

  /// Recupera el historial completo de notificaciones y actualiza el estado.
  Future<void> cargar() async {
    // Usamos el caso de uso
    state = await getNotificaciones();
  }

  /// Crea una nueva notificación con el [titulo] y [cuerpo] proporcionados,
  /// la guarda en la base de datos y refresca la lista mostrada.
  Future<void> agregar(String titulo, String cuerpo) async {
    final userId = await StorageService.obtenerSesion() ?? 0;
    final nueva = Notifications(
      titulo: titulo,
      cuerpo: cuerpo,
      fecha: DateTime.now(),
      usuariosId: userId,
    );
    await guardarNotificacion(nueva);
    await cargar();
  }

  /// Marca todas las notificaciones actuales como "leidas" en la base de datos
  /// y luego refresca la lista mostrada en la app.
  Future<void> marcarComoLeidas() async {
    await marcarLeidas();
    await cargar();
  }

  /// Borra el historial completo de notificaciones de la base de datos
  /// y vacia la lista actual en memoria.
  Future<void> limpiar() async {
    await eliminarNotificaciones();
    state = [];
  }
}
