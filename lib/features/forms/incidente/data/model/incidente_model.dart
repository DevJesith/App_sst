import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';

/// Modelo de datos para la tabla.
/// Extiende la entidad de dominio y agrega metodos de serializacion
class IncidenteModel extends Incidente {
  const IncidenteModel({
    int? id,
    required String eventualidad,
    required int proyectoId,
    required String mes,
    required String descripcion,
    required int diasIncapacidad,
    required String avances,
    required String estado,
    required DateTime fechaRegistro,
    int sincronizado = 0,
    required int usuarioId,
  }) : super(
         id: id,
         eventualidad: eventualidad,
         proyectoId: proyectoId,
         mes: mes,
         descripcion: descripcion,
         diasIncapacidad: diasIncapacidad,
         avances: avances,
         estado: estado,
         fechaRegistro: fechaRegistro,
         sincronizado: sincronizado,
         usuarioId: usuarioId,
       );

  /// Crea una instancia desde un Mapa
  factory IncidenteModel.fromMap(Map<String, dynamic> map) {
    return IncidenteModel(
      id: map['id'] as int?,
      eventualidad: map['eventualidad'] as String? ?? '',
      proyectoId: map['Proyecto_id'] as int? ?? 0,
      mes: map['mes'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      diasIncapacidad: map['dias_incapacidad'] as int? ?? 0,
      avances: map['avances'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      fechaRegistro: map['fecha_registro'] != null 
          ? DateTime.parse(map['fecha_registro'] as String) 
          : DateTime.now(),
      sincronizado: map['sincronizado'] as int? ?? 0,
      usuarioId: map['Usuarios_id'] as int? ?? 0,
    );
  }

  /// Convierte la instancia a un Mapa para insertar en la BD.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventualidad': eventualidad,
      'Proyecto_id': proyectoId,
      'mes': mes,
      'descripcion': descripcion,
      'dias_incapacidad': diasIncapacidad,
      'avances': avances,
      'estado': estado,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'sincronizado': sincronizado,
      'Usuarios_id': usuarioId,
    };
  }

  IncidenteModel copyWith({
    int? id,
    String? eventualidad,
    int? proyectoId,
    String? mes,
    String? descripcion,
    int? diasIncapacidad,
    String? avances,
    String? estado,
    DateTime? fechaRegistro,
    int? sincronizado,
    int? usuarioId,
  }) {
    return IncidenteModel(
      id: id ?? this.id,
      eventualidad: eventualidad ?? this.eventualidad,
      proyectoId: proyectoId ?? this.proyectoId,
      mes: mes ?? this.mes,
      descripcion: descripcion ?? this.descripcion,
      diasIncapacidad: diasIncapacidad ?? this.diasIncapacidad,
      avances: avances ?? this.avances,
      estado: estado ?? this.avances,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      sincronizado: sincronizado ?? this.sincronizado,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }
}
