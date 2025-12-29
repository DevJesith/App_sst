import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Utilidad para el mantenimiento y limpieza de la base de datos
class DatabaseResetter {

  /// Elimina fisicamente el archuvo de la base de datos local.
  /// 
  /// ⚠️ **ADVERTENCIA:** Esta acción es irreversible. 
  /// se perderan todos los datos guardados localmente
  /// 
  /// Util para: 
  /// * Reiniciar la aplicacion a estado de fabrica durante el desarrollo
  /// * Limpiar datos corruptos o esquemas desactualizados.
  /// * Simular una instancia limpia.
  
  static Future<void> eliminarBD() async {
    try {
      
      final dbPath = await getDatabasesPath();

      // Nombre de la bd
      final path = join(dbPath, 'appsst_final_v1.db');

      await deleteDatabase(path);

      debugPrint("✅ Base de datos eliminada correctamente: $path");
    } catch (e) {
      debugPrint("❌ Error al eliminar la base de datos: $e");
    }
  }

}