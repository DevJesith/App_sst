import 'package:app_sst/features/notifications/domain/entities/notification.dart';

/// Modelo de datos para las notificaciones.
/// 
/// Extiende de la entidad [Notifications] para agregar funcionalidades 
/// especificas de la capa de datos, como la serializacion y deserializacion
/// hacia y desde SQLite.
class NotificationModel extends Notifications {
  NotificationModel({
    int? id,
    required String titulo,
    required String cuerpo,
    required DateTime fecha,
    bool leido = false,
    required int usuariosId,
  }) : super(
         id: id,
         titulo: titulo,
         cuerpo: cuerpo,
         fecha: fecha,
         leido: leido,
         usuariosId: usuariosId,
       );

  /// Construye una instancia de [NotificationModel] a partir de un [Map] (diccionario).
  /// 
  /// Util para convertir los resultados crudos de una consulta a la base de datos
  /// (SQLite) en un objeto Dart utilizable.
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      titulo: map['titulo'],
      cuerpo: map['cuerpo'],
      fecha: DateTime.parse(map['fecha']),
      leido: map['leido'] == 1,
      usuariosId: map['Usuarios_id'] as int? ?? 0,
    );
  }

  /// Convierte la instancia actual en un [Map] de pares clave-valor.
  /// 
  /// Util para preparar el objeto antes de insertarlo o actualizarlo
  /// en la base de datos (SQLite). Convierte las fechas a formato 
  /// ISO8601 y los valores booleanos a enteros (`1` o `0`).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'cuerpo': cuerpo,
      'fecha': fecha.toIso8601String(),
      'leido': leido ? 1 : 0,
      'Usuarios_id': usuariosId,
    };
  }
}
