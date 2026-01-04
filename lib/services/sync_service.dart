import 'package:app_sst/data/database/app_database.dart';
import 'package:app_sst/services/connectivity_service.dart';

/// Servicio encargado de la sincronizacion de datos.
/// 
/// Esta version implemnta una **SIMULACION** del proceso de sincronizacion
/// para hacer pruebas de demostracion.
/// 
/// En un entorno de produccion, este servicio se conectaria con una API REST
/// para realizar el intercambio real de datos.
class SyncService {
  final AppDatabase _appDatabase = AppDatabase();

  /// Ejecuta el proceso de sincronizacion simulado.
  /// 1. Verifica si hay internet
  /// 1. Simula un retardo de red (2 segundos).
  /// 2. Busca registros locales con estado sincronizado = 0.
  /// 3. Actualiza el estado a sincronizado = 1 (verde).
  /// 4. Retorna un reporte con la cantidad de registros procesados.
  Future<Map<String, int>> sincronizarTodo() async {

    // 1. Freno de emergencia: Si no hay internte, no hacemos nada.
    final hayInternet = await ConnectivityService.tieneInternet();
    if (!hayInternet) {
      return {
        'total': 0,
        'accidentes': 0,
        'incidentes': 0,
        'gestiones': 0,
        'capacitaciones': 0, 
        'enfermedades': 0, 
      };
    }

    final db = await _appDatabase.database;
    
    // 2. Simular tiempo de espera de red para realismo (UX)
    await Future.delayed(const Duration(seconds: 2));

    int totalSincronizados = 0;

    // Funcion auxiliar para actualizar tablas localmente
    Future<int> simularEnvioTabla(String tabla) async {
      // Contamos cuantos hay pendientes
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

    // 3. Actualizar todas las tablas (Simulacion de subida)
    int acc = await simularEnvioTabla('Accidente');
    int inc = await simularEnvioTabla('Incidente');
    int ges = await simularEnvioTabla('Gestion_inspeccion');
    int cap = await simularEnvioTabla('Capacitacion');
    int enf = await simularEnvioTabla('Enfermedad_Laboral');

    totalSincronizados = acc + inc + ges + cap + enf;

    // 4. Retornar reporte de resultados
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