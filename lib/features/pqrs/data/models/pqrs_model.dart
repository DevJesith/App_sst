import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';

class PqrsModel extends Pqrs {
  PqrsModel({
    int? id,
    required String tipo,
    required String nombreSolicitante,
    required String correoContacto,
    required String descripcion,
    required DateTime fechaCreacion,
    String estado = 'Pendiente',
  }) : super(
         id: id,
         tipo: tipo,
         nombreSolicitante: nombreSolicitante,
         correoContacto: correoContacto,
         descripcion: descripcion,
         fechaCreacion: fechaCreacion,
         estado: estado,
       );

  factory PqrsModel.fromMap(Map<String, dynamic> map) {
    return PqrsModel(
      id: map['id'],
      tipo: map['tipo'],
      nombreSolicitante: map['nombre_solicitante'],
      correoContacto: map['correo_contacto'],
      descripcion: map['descripcion'],
      fechaCreacion: DateTime.parse(map['fecha_creacion']),
      estado: map['estado'] ?? 'Pendiente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'nombre_solicitante': nombreSolicitante,
      'correo_contacto': correoContacto,
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'estado': estado,
    };
  }
}
