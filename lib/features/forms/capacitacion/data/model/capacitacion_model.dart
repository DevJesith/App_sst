// features/forms/capacitacion/data/models/capacitacion_model.dart

import '../../domain/entities/capacitacion.dart';

class CapacitacionModel extends Capacitacion {
  const CapacitacionModel({
    int? id,
    required int idProyecto,
    required int idContratista,
    required String descripcion,
    required int numeroCapacita,
    required int numeroPersonas,
    required String responsable,
    required DateTime fechaRegistro,
    int sincronizado = 0,
    required int usuarioId,
  }) : super(
          id: id,
          idProyecto: idProyecto,
          idContratista: idContratista,
          descripcion: descripcion,
          numeroCapacita: numeroCapacita,
          numeroPersonas: numeroPersonas,
          responsable: responsable,
          fechaRegistro: fechaRegistro,
          sincronizado: sincronizado,
          usuarioId: usuarioId,
        );

  factory CapacitacionModel.fromMap(Map<String, dynamic> map) {
    return CapacitacionModel(
      id: map['id'] as int?,
      idProyecto: map['Proyecto_id'] as int,
      idContratista: map['Contratista_id'] as int,
      descripcion: map['Descripcion'] as String,
      numeroCapacita: map['Numero_capacita'] as int,
      numeroPersonas: map['Numero_personas'] as int,
      responsable: map['Responsable'] as String,
      fechaRegistro: DateTime.parse(map['fecha_registro'] as String),
      sincronizado: map['sincronizado'] as int? ?? 0,
      usuarioId: map['usuarios_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Proyecto_id': idProyecto,
      'Contratista_id': idContratista,
      'Descripcion': descripcion,
      'Numero_capacita': numeroCapacita,
      'Numero_personas': numeroPersonas,
      'Responsable': responsable,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'sincronizado': sincronizado,
      'usuarios_id': usuarioId,
    };
  }

  CapacitacionModel copyWith({
    int? id,
    int? idProyecto,
    int? idContratista,
    String? descripcion,
    int? numeroCapacita,
    int? numeroPersonas,
    String? responsable,
    DateTime? fechaRegistro,
    int? sincronizado,
    int? usuarioId,
  }) {
    return CapacitacionModel(
      id: id ?? this.id,
      idProyecto: idProyecto ?? this.idProyecto,
      idContratista: idContratista ?? this.idContratista,
      descripcion: descripcion ?? this.descripcion,
      numeroCapacita: numeroCapacita ?? this.numeroCapacita,
      numeroPersonas: numeroPersonas ?? this.numeroPersonas,
      responsable: responsable ?? this.responsable,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      sincronizado: sincronizado ?? this.sincronizado,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }
}