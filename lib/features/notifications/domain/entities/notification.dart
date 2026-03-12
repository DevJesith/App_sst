
/// Entidad de dominio que representa una Notificacion dentro del sistema.
/// 
/// Contiene la informacion esencial de una alerta o mensaje para el usuario:
/// * [id]: Identificador unico de la notificacion.
/// * [titulo]: El encabezado o asunto de la notificacion.
/// * [cuerpo]: El mensaje detallado de la notificacion.
/// * [fecha]: La fecha y hora de emision de la notificación.
/// * [leido]: Estado que indica si el usuario ya vio la notificacion.
class Notifications {
  final int? id;
  final String titulo;
  final String cuerpo;
  final DateTime fecha;
  final bool leido;
  final int usuariosId;

  Notifications({
    this.id,
    required this.titulo,
    required this.cuerpo,
    required this.fecha,
    this.leido = false,
    required this.usuariosId,
  });
}
