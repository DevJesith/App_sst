import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/notifications/data/models/notification_model.dart';
import 'package:app_sst/services/storage_service.dart';

/// Interfaz para el acceso a datos locales de Notificaciones
/// 
/// Define las operaciones CRUD usando el modelo de datos de la capa local.
abstract class NotificationLocalDatasource {
  Future<List<NotificationModel>> getNotificaciones();
  Future<void> guardarNotificacion(NotificationModel notificacion);
  Future<void> marcarTodasComoLeidas();
  Future<void> eliminarTodas();
}

/// Implementacion concreta del DataSource local usando SQLite.
///
/// Se encarga de interactuar directamente con la base de datos local
/// para realizar las operaciones de lectura y escritura (CRUD) de notificaciones.
class NotificationLocalDataSourceImpl implements NotificationLocalDatasource {
  /// Instancia de manejo de conexiones y tablas de la base de datos de la aplicación.
  final AppDatabase database;

  NotificationLocalDataSourceImpl({required this.database});

  /// Obtiene la lista local de notificaciones.
  ///
  /// Consulta a la tabla `Notificaciones` y retorna los registros convertidos
  /// en instancias de [NotificationModel]. Los resultados estan ordenados
  /// cronologicamente, de mas reciente a mas antigua.
  @override
  Future<List<NotificationModel>> getNotificaciones() async {
    final db = await database.database;
    final userId = await StorageService.obtenerSesion() ?? 0;
    final res = await db.query(
      'Notificaciones', 
      where: 'Usuarios_id = ?',
      whereArgs: [userId],
      orderBy: 'fecha DESC'
    );
    return res.map((e) => NotificationModel.fromMap(e)).toList();
  }

  /// Guarda una nueva [notificacion] en la base de datos local.
  ///
  /// Requiere un [NotificationModel] y utiliza su metodo `toMap()` para
  /// la insercion en la tabla `Notificaciones`.
  @override
  Future<void> guardarNotificacion(NotificationModel notificacion) async {
    final db = await database.database;
    await db.insert('Notificaciones', notificacion.toMap());
  }

  /// Actualiza el estado de lectura de multiples notificaciones.
  ///
  /// Busca todas las notificaciones donde la columna `leido` sea `0` (false)
  /// y las actualiza a `1` (true).
  @override
  Future<void> marcarTodasComoLeidas() async {
    final db = await database.database;
    final userId = await StorageService.obtenerSesion() ?? 0;
    await db.update(
      'Notificaciones', 
      {'leido': 1}, 
      where: 'leido = 0 AND Usuarios_id = ?',
      whereArgs: [userId],
    );
  }

  /// Limpia por completo la tabla local de notificaciones.
  ///
  /// Esto borra de la base de datos todas las notificaciones que el usuario tenga.
  @override
  Future<void> eliminarTodas() async {
    final db = await database.database;
    final userId = await StorageService.obtenerSesion() ?? 0;
    await db.delete('Notificaciones', where: 'Usuarios_id = ?', whereArgs: [userId]);
  }
}
