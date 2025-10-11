import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio para verificar si el dispositivo tiene conexión a internet.
/// Utiliza el paquete `connectivity_plus` para detectar el estado de red.
class ConnectivityService {

  /// Retorna `true` si hay conexión (WiFi, móvil, etc.), `false` si no hay.
  static Future<bool> tieneInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
