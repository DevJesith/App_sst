import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';

/// Modelo de datos para la tabla Pqrs
/// Extiende la entidad de dominio y agrega metodos de serializacion
class PqrsModel extends Pqrs {
  PqrsModel({
    int? id,
    required String tipo,
    required String nombreSolicitante,
    required String telefonoContacto,
    required String correoContacto,
    required String descripcion,
    required DateTime fechaCreacion,
    String estado = 'Pendiente',
  }) : super(
         id: id,
         tipo: tipo,
         nombreSolicitante: nombreSolicitante,
         telefonoContacto: telefonoContacto,
         correoContacto: correoContacto,
         descripcion: descripcion,
         fechaCreacion: fechaCreacion,
         estado: estado,
       );

  /// Crea una instancia desde Mapa BD
  factory PqrsModel.fromMap(Map<String, dynamic> map) {
    return PqrsModel(
      id: map['id'],
      tipo: map['tipo'],
      nombreSolicitante: map['nombre_solicitante'],
      telefonoContacto: map['telefono_contacto'],
      correoContacto: map['correo_contacto'],
      descripcion: map['descripcion'],
      fechaCreacion: DateTime.parse(map['fecha_creacion']),
      estado: map['estado'] ?? 'Pendiente',
    );
  }

  /// Convierte la instancia a un Mapa para insertar en la BD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'nombre_solicitante': nombreSolicitante,
      'telefono_contacto': telefonoContacto,
      'correo_contacto': correoContacto,
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'estado': estado,
    };
  }
}
