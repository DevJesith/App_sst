import 'package:app_sst/core/data/database/app_database.dart';
import 'package:app_sst/features/notifications/data/models/notification_model.dart';

class NotificationLocalDatasource {
  final AppDatabase database;

  NotificationLocalDatasource({required this.database});

  Future<List<NotificationModel>> getNotificaciones() async {
    final db = await database.database;
    final res = await db.query('Notificaciones', orderBy: 'fecha DESC');
    return res.map((e) => NotificationModel.fromMap(e)).toList();
  }

  Future<void> insertNotificacion(NotificationModel notificacion) async {
    final db = await database.database;
    await db.insert('Notificaciones', notificacion.toMap());
  }

  Future<void> markAllAsRead() async {
    final db = await database.database;
    await db.update('Notificaciones', {'leido': 1}, where: 'leido = 0');
  }

  Future<void> deleteAll() async {
    final db = await database.database;
    await db.delete('Notificaciones');
  }
}
