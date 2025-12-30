import 'dart:async';
import 'package:app_sst/services/notification_service.dart';
import 'package:app_sst/services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 

class ConnectivityManager {
  // Instancia unica (Singleton)
  static final ConnectivityManager _instance = ConnectivityManager._internal();
  factory ConnectivityManager() => _instance;
  ConnectivityManager._internal();

  final Connectivity _connectivity = Connectivity();
  final SyncService _syncService = SyncService();
  final NotificationService _notificationService = NotificationService();

  StreamSubscription? _subscription;

  /// Inicia la escucha automática de la red
  void initialize() {
    // 1. Verificar conexión inicial al abrir la app
    _checkInitialConnection();

    // 2. Escuchar cambios en tiempo real (Se fue el internet / Volvió el internet)
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _procesarCambioDeConexion(results);
    });
  }

  void _checkInitialConnection() async {
    final results = await _connectivity.checkConnectivity();
    _procesarCambioDeConexion(results);
  }

  void _procesarCambioDeConexion(List<ConnectivityResult> results) {
    // Si hay conexión Móvil o WiFi
    if (results.contains(ConnectivityResult.mobile) || 
        results.contains(ConnectivityResult.wifi) || 
        results.contains(ConnectivityResult.ethernet)) {
      
      print("🌐 CONEXION DETECTADA: Iniciando sincronizacion automatica...");
      
      // Llamamos a tu servicio de sincronización
      _syncService.sincronizarTodo().then((resultado) {
        if (resultado['total']! > 0) {
          print("✅ AUTO-SYNC: Se subieron ${resultado['total']} registros a la nube.");

          // LANZAR NOTIFICACION
          _notificationService.showNotificacion(
            id: 1,
            title: 'Sincronizacion Completada',
            body: 'Se han subido ${resultado['total']} reportes a la nube exitosamente.',
          );
          
        } else {
          print("💤 AUTO-SYNC: No había datos pendientes.");
        }
      }).catchError((e) {
        print("❌ AUTO-SYNC ERROR: $e");
      });
    } else {
      print("⚠️ SIN CONEXIÓN: Los datos se guardarán localmente.");
    }
  }

  // Detener la escucha (opcional, por si cierras sesión)
  void dispose() {
    _subscription?.cancel();
  }
}