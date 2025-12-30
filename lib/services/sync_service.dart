import 'package:app_sst/data/database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class SyncService {
  final AppDatabase _appDatabase = AppDatabase();

  /// Simula el envío de datos a la nube y la descarga de actualizaciones
  Future<Map<String, int>> sincronizarTodo() async {
    final db = await _appDatabase.database;
    
    // 1. Simular tiempo de espera de red (2 segundos) para realismo
    await Future.delayed(const Duration(seconds: 2));

    int totalSincronizados = 0;

    // Función auxiliar para actualizar tablas localmente
    Future<int> simularEnvioTabla(String tabla) async {
      // Contamos cuántos hay pendientes
      final pendientes = await db.query(tabla, where: 'sincronizado = 0');
      if (pendientes.isNotEmpty) {
        // Los marcamos como subidos (sincronizado = 1)
        await db.update(
          tabla, 
          {'sincronizado': 1}, 
          where: 'sincronizado = 0'
        );
        return pendientes.length;
      }
      return 0;
    }

    // 2. Actualizar todas las tablas (Simulación de Subida)
    int acc = await simularEnvioTabla('Accidente');
    int inc = await simularEnvioTabla('Incidente');
    int ges = await simularEnvioTabla('Gestion_inspeccion');
    int cap = await simularEnvioTabla('Capacitacion');
    int enf = await simularEnvioTabla('Enfermedad_Laboral');

    totalSincronizados = acc + inc + ges + cap + enf;

    // 3. Retornar reporte
    return {
      'total': totalSincronizados,
      'accidentes': acc,
      'incidentes': inc,
      'gestiones': ges,
      'capacitaciones': cap,
      'enfermedades': enf,
    };
  }
}