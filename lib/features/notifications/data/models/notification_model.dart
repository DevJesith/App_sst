import 'package:app_sst/features/notifications/domain/entities/notification.dart';

class NotificationModel extends Notifications {
  NotificationModel({
    int? id,
    required String titulo,
    required String cuerpo,
    required DateTime fecha,
    bool leido = false,
  }) : super(
         id: id,
         titulo: titulo,
         cuerpo: cuerpo,
         fecha: fecha,
         leido: leido,
       );

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      titulo: map['titulo'],
      cuerpo: map['cuerpo'],
      fecha: DateTime.parse(map['fecha']),
      leido: map['leido'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'cuerpo': cuerpo,
      'fecha': fecha.toIso8601String(),
      'leido': leido ? 1 : 0,
    };
  }
}
