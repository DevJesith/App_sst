import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyUserId = 'auth_use_id';

  /// Guarda el ID del usuario logueado
  static Future<void> guardarSesion(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, id);
  }

  /// Obtiene el ID del usuario guardado (o null si no hay sesion)
  static Future<int?> obtenerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Borra la sesion (Logout)
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }
}
