import 'dart:async';
import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:app_sst/features/notifications/data/repositories_impl/notification_repository_impl.dart';
import 'package:app_sst/features/notifications/domain/entities/notification.dart';
import 'package:app_sst/services/notification_service.dart';
import 'package:app_sst/services/sync_service.dart';
import 'package:app_sst/services/storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/animation.dart';

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

  // Actualizar la campanita
  VoidCallback? onSyncCompleted;

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

  // Instancia manual del repositorio (Clean Architecture)
  final _notificationRepo = NotificationRepositoryImpl(
    localDatasource: NotificationLocalDataSourceImpl(database: AppDatabase()),
  );

  bool _isSyncing = false;

  /// Logica central: Decide que hacer segun el estado de red.
  void _procesarCambioDeConexion(List<ConnectivityResult> results) async {
    // Verificar si hay algun tipo de conexion valida
    bool hayConexion =
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);

    if (hayConexion) {
      if (_isSyncing) {
        print("⏳ Sincronización ya en progreso. Ignorando señal duplicada...");
        return;
      }

      _isSyncing = true;
      print("🌐 CONEXION DETECTADA: Iniciando sincronizacion automatica...");

      try {
        final resultado = await _syncService.sincronizarTodo();

        // Si hubo datos procesados, notificar al usuario
        if (resultado['total']! > 0) {
          String cuerpoDetallado = _construirMensajeDetallado(resultado);

          // Lanzar notificacion local
          _notificationService.showNotificacion(
            id: 1,
            title: 'Sincronizacion Completada',
            body: 'Se han subido ${resultado['total']} registros',
          );

          // Guardar en BD
          final userId = await StorageService.obtenerSesion() ?? 0;
          await _notificationRepo.guardarNotificacion(
            Notifications(
              titulo: 'Sincronizacion Exitosa',
              cuerpo: cuerpoDetallado,
              fecha: DateTime.now(),
              usuariosId: userId,
            ),
          );

          onSyncCompleted?.call();
        } else {
          print("💤 AUTO-SYNC: No había datos pendientes.");
        }
      } catch (e) {
        print("❌ AUTO-SYNC ERROR: $e");
      } finally {
        _isSyncing = false;
      }
    } else {
      print("⚠️ SIN CONEXIÓN: Los datos se guardarán localmente.");
    }
  }

  String _construirMensajeDetallado(Map<String, int> res) {
    List<String> detalles = [];

    if ((res['accidentes'] ?? 0) > 0)
      detalles.add("• ${res['accidentes']} Accidentes");
    if ((res['incidentes'] ?? 0) > 0)
      detalles.add("• ${res['incidentes']} Incidentes");
    if ((res['gestiones'] ?? 0) > 0)
      detalles.add("• ${res['gestiones']} Gestiones");
    if ((res['capacitaciones'] ?? 0) > 0)
      detalles.add("• ${res['capacitaciones']} Capacitaciones");
    if ((res['enfermedades'] ?? 0) > 0)
      detalles.add("• ${res['enfermedades']} Enf. Laborales");

    if (detalles.isEmpty) return "Sincronizacion general completada.";

    return "Se subieron exitosamente:\n${detalles.join('\n')}";
  }

  // Detener la escucha de red. Util al cerrar sesion o destruir la app.
  void dispose() {
    _subscription?.cancel();
  }
}
