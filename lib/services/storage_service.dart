import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de almacenamiento ligero para persistencia de datos simples.
/// 
/// Se utiliza exclusivamente para mantener la **Sesion del Usuario** activa
/// (guardando su ID) inclusos si la aplicacion se cierra completamente.
class StorageService {
  // Clave interna para guardar el ID
  static const String _keyUserId = 'auth_user_id';

  /// Guarda el ID del usuario logueado en el almacenamiento del dispositivo.
  static Future<void> guardarSesion(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, id);
  }

  /// Recupera el ID del usuario guardado.
  /// Retorna null si no hay ninguna sesion activa.
  static Future<int?> obtenerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Elimina el ID del usuario (Cerrar sesion).
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }
}
