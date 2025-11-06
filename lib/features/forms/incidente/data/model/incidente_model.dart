import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';

class IncidenteModel extends Incidente {
  const IncidenteModel({
    int? id,
    required String eventualidad,
    required String proyecto,
    required String contratista,
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
         proyecto: proyecto,
         contratista: contratista,
         mes: mes,
         descripcion: descripcion,
         diasIncapacidad: diasIncapacidad,
         avances: avances,
         estado: estado,
         fechaRegistro: fechaRegistro,
         sincronizado: sincronizado,
         usuarioId: usuarioId,
       );

  factory IncidenteModel.fromMap(Map<String, dynamic> map) {
    return IncidenteModel(
      id: map['id'] as int?,
      eventualidad: map['eventualidad'] as String,
      proyecto: map['proyecto'] as String,
      contratista: map['contratista'] as String,
      mes: map['mes'] as String,
      descripcion: map['descripcion'] as String,
      diasIncapacidad: map['dias_incapacidad'] as int,
      avances: map['avances'] as String,
      estado: map['estado'] as String,
      fechaRegistro: DateTime.parse(map['fecha_registro'] as String),
      sincronizado: map['sincronizado'] as int? ?? 0,
      usuarioId: map['Usuarios_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventualidad': eventualidad,
      'proyecto': proyecto,
      'contratista': contratista,
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
    String? proyecto,
    String? contratista,
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
      proyecto: proyecto ?? this.proyecto,
      contratista: contratista ?? this.contratista,
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
