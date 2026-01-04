import 'package:app_sst/services/connectivity_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio utilitario para verificaciones puntuales de conectividad.
///
/// A diferencia del [ConnectivityManager] que escucha cambios constantes,
/// esta clase se usa para pregunra "¿Tengo internet ahora mismo?" antes de una accion especifica.
class ConnectivityService {
  /// Verifica si el dispositivo tiene conexion activa (Wifi, Movil, Ethernet).
  ///
  /// Retorna true si hay conexion, false si no
  static Future<bool> tieneInternet() async {
    final result = await Connectivity().checkConnectivity();

    // Verifica si hay algun modo de internet activa
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }
}
