import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';


/// Modelo de datos para la tabla Accidente.
/// Extiende la entidad de dominio y agrega metodos de serializacion
class AccidenteModel extends Accidente {
  const AccidenteModel({
    int? id,
    required String eventualidad,
    required int proyectoId,
    required int contratistaId,
    required String descripcion,
    required int diasIncapacidad,
    required String avances,
    required String estado,
    required DateTime fechaRegistro,
    required DateTime fechaCreacion,
    int sincronizado = 0,
    required int usuarioId,
  }) : super (
    id: id,
    eventualidad: eventualidad,
    proyectoId: proyectoId,
    contratistaId: contratistaId,
    descripcion: descripcion,
    diasIncapacidad: diasIncapacidad,
    avances: avances,
    estado: estado,
    fechaRegistro: fechaRegistro,
    fechaCreacion: fechaCreacion,
    sincronizado: sincronizado,
    usuarioId: usuarioId,
  );

  /// Crea una instancia desde un Mapa BD
  factory AccidenteModel.fromMap(Map<String, dynamic> map){
    return AccidenteModel(
      id: map['id'] as int?,
      eventualidad: map['eventualidad'] as String? ?? '',
      proyectoId: map['Proyecto_id'] as int? ?? 0,
      contratistaId: map['Contratista_id'] as int? ?? 0,
      descripcion: map['descripcion'] as String? ?? '',
      diasIncapacidad: map['dias_incapacidad'] as int? ?? 0,
      avances: map['avances'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      fechaRegistro: DateTime.parse(map['fecha_registro'] as String),
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
      sincronizado: map['sincronizado'] as int? ?? 0,
      usuarioId: map['Usuarios_id'] as int? ?? 0,
    );
  }

  /// Convierte la instancia a un Mapa para insertar en la BD
  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'eventualidad': eventualidad,
      'Proyecto_id': proyectoId,
      'Contratista_id': contratistaId,
      'descripcion': descripcion,
      'dias_incapacidad': diasIncapacidad,
      'avances': avances,
      'estado':estado,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'sincronizado':sincronizado,
      'Usuarios_id': usuarioId
    };
  }
  
  AccidenteModel copyWith({
    int? id,
    String? eventualidad,
    int? proyectoId,
    int? contratistaId,
    String? mes,
    String? descripcion,
    int? diasIncapacidad,
    String? avances,
    String? estado,
    DateTime? fechaRegistro,
    DateTime? fechaCreacion,
    int? sincronizado,
    int? usuarioId,
  }){
    return AccidenteModel(
      id: id ?? this.id,
      eventualidad: eventualidad ?? this.eventualidad,
      proyectoId: proyectoId ?? this.proyectoId,
      contratistaId: contratistaId ?? this.contratistaId,
      descripcion: descripcion ?? this.descripcion,
      diasIncapacidad: diasIncapacidad ?? this.diasIncapacidad,
      avances: avances ?? this.avances,
      estado: estado ?? this.estado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      sincronizado: sincronizado ?? this.sincronizado,
      usuarioId: usuarioId ?? this.usuarioId
    );
  }
}