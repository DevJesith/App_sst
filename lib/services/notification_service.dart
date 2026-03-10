import 'package:app_sst/features/notifications/presentation/screens/notificaciones_screen.dart';
import 'package:app_sst/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service encargado de gestionar las notificaciones locales del dispositivo.
///
/// Utiliza el patron Singleton para asaegurar una unica instancia.
/// Se usa principalmente para dar feedback al usuario cuando la sincronizacion
/// automatica se completa en segundo plano.
class NotificationService {
  // --- Patron Singleton ---
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el plugin de notificaciones y solicita permisos.
  ///
  /// Debe llamarse en el main.dart antes de arrancar la app.
  Future<void> initialize() async {
    // Configuracion para Android
    // '@mipmap/ic_launcher' usa el icono nativo de la app
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuracion para IOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Esto se ejecuta cuando el usuario toca la notificacion
        _onNotificationTapped();
      },
    );

    // Solicitar permisos explicitos en Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTapped() {
    // Usamos la llave global para nevegar sin necesidad de un BuildContext
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
      );
    }
  }

  /// Muestra una notificacion inmediata en la barra de estado.
  ///
  /// * [id]: Identificador unico
  /// * [title]: Titulo en negrita.
  /// * [body]: Mensaje descriptivo.
  Future<void> showNotificacion({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'channel_sst_sync', // ID del canal
          'Sincronizacion SST', // Nombre visible para el usuario e ajustes
          channelDescription: 'Notificaciones de estado de sincronizacion',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(id, title, body, platformChannelSpecifics);
  }
}
