import '../../domain/entities/capacitacion.dart';

/// Modelo de datos para la tabla 
/// Extiende la entidad de dominio y agrega metodos de serializacion.
class CapacitacionModel extends Capacitacion {
  const CapacitacionModel({
    int? id,
    required int idProyecto,
    required int idContratista,
    required String descripcion,
    required int numeroCapacita,
    required int numeroPersonas,
    required String responsable,
    required String tema,
    required DateTime fechaRegistro,
    required DateTime fechaCreacion,
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
          tema: tema,
          fechaRegistro: fechaRegistro,
          fechaCreacion: fechaCreacion,
          sincronizado: sincronizado,
          usuarioId: usuarioId,
        );

  /// Crea una instancia desde un Mapa BD.
  factory CapacitacionModel.fromMap(Map<String, dynamic> map) {
    return CapacitacionModel(
      // Mapeo de nombres de columnas de la BD a propiedades del modelo
      id: map['id'] as int?,
      idProyecto: map['Proyecto_id'] as int? ?? 0,
      idContratista: map['Contratista_id'] as int? ?? 0,
      descripcion: map['Descripcion'] as String? ?? '',
      numeroCapacita: map['Numero_capacita'] as int? ?? 0,
      numeroPersonas: map['Numero_personas'] as int? ?? 0,
      responsable: map['Responsable'] as String? ?? '',
      tema: map['Tema'] as String? ?? '',
      fechaRegistro: DateTime.parse(map['fecha_registro'] as String),
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
      sincronizado: map['sincronizado'] as int? ?? 0,
      usuarioId: map['Usuarios_id'] as int? ?? 0,
    );
  }

  /// Convierte la instancia a un Mapa para insertar en la BD.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Proyecto_id': idProyecto,
      'Contratista_id': idContratista,
      'Descripcion': descripcion,
      'Numero_capacita': numeroCapacita,
      'Numero_personas': numeroPersonas,
      'Responsable': responsable,
      'Tema': tema,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'fecha_creacion': fechaCreacion.toIso8601String(),
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
    String? tema,
    DateTime? fechaRegistro,
    DateTime? fechaCreacion,
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
      tema: tema ?? this.tema,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      sincronizado: sincronizado ?? this.sincronizado,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }
}