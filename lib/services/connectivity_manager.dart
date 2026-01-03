import 'dart:async';
import 'package:app_sst/services/notification_service.dart';
import 'package:app_sst/services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Gestor centrar de connectividad.
///
/// Se encarga de escuchar los cambios en la red (Wifi/Datos) y disparar
/// automaticamente el proceso de sincronizacioncuando se recupera la conexion.
///
/// Implementa el patron Singleton para asefgura una unica instancia en toda la app.
class ConnectivityManager {
  // --- Patron Singleton ---
  static final ConnectivityManager _instance = ConnectivityManager._internal();
  factory ConnectivityManager() => _instance;
  ConnectivityManager._internal();

  // Dependecias
  final Connectivity _connectivity = Connectivity();
  final SyncService _syncService = SyncService();
  final NotificationService _notificationService = NotificationService();

  StreamSubscription? _subscription;

  /// Inicia la escucha activda del estado ed la red.
  /// Debe llamarse en el main.dart al iniciar la aplicacion.
  void initialize() {
    // 1. Verificar estado inciial
    _checkInitialConnection();

    // 2. Suscribirse a cambios en tiempo real
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _procesarCambioDeConexion(results);
    });
  }

  /// Verifica la conexion al arrancar la app.
  void _checkInitialConnection() async {
    final results = await _connectivity.checkConnectivity();
    _procesarCambioDeConexion(results);
  }

  /// Logica central: Decide que hacer segun el estado de red.
  void _procesarCambioDeConexion(List<ConnectivityResult> results) {
    // Verificar si hay algun tipo de conexion valida
    bool hayConexion =
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);

    if (hayConexion) {
      print("🌐 CONEXION DETECTADA: Iniciando sincronizacion automatica...");

      // Ejecutar sincronizacion (Subida y Bajada)
      _syncService
          .sincronizarTodo()
          .then((resultado) {

            // Si hubo datos procesados, notificar al usuario
            if (resultado['total']! > 0) {
              print(
                "✅ AUTO-SYNC: Se subieron ${resultado['total']} registros a la nube.",
              );

              // Lanzar notificacion local
              _notificationService.showNotificacion(
                id: 1,
                title: 'Sincronizacion Completada',
                body:
                    'Se han subido ${resultado['total']} reportes a la nube exitosamente.',
              );
            } else {
              print("💤 AUTO-SYNC: No había datos pendientes.");
            }
          })
          .catchError((e) {
            print("❌ AUTO-SYNC ERROR: $e");
          });
    } else {
      print("⚠️ SIN CONEXIÓN: Los datos se guardarán localmente.");
    }
  }

  // Detener la escucha de red. Util al cerrar sesion o destruir la app.
  void dispose() {
    _subscription?.cancel();
  }
}
