import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';

class GestionModel extends Gestion {
  const GestionModel({
    int? id,
    required String ee,
    required String proyecto,
    required String epp,
    required String locativa,
    required String extintorMaquina,
    required String rutinariaMaquina,
    required String gestionCumple,
    required String foto1,
    required String foto2,
    required String foto3,
    required DateTime fechaRegistro,
    int sincronizado = 0,
    required int usuarioId,
  }) : super(
         id: id,
         ee: ee,
         proyecto: proyecto,
         epp: epp,
         locativa: locativa,
         extintorMaquina: extintorMaquina,
         rutinariaMaquina: rutinariaMaquina,
         gestionCumple: gestionCumple,
         foto1: foto1,
         foto2: foto2,
         foto3: foto3,
         fechaRegistro: fechaRegistro,
         sincronizado: sincronizado,
         usuarioId: usuarioId,
       );

  factory GestionModel.fromMap(Map<String, dynamic> map) {
    return GestionModel(
      id: map['id'] as int?,
      ee: map['ee'] as String,
      proyecto: map['proyecto'] as String,
      epp: map['epp'] as String,
      locativa: map['locativa'] as String,
      extintorMaquina: map['extintor_maquina'] as String,
      rutinariaMaquina: map['rutinaria_maquina'] as String,
      gestionCumple: map['gestion_cumple'] as String,
      foto1: map['foto1'] as String,
      foto2: map['foto2'] as String,
      foto3: map['foto3'] as String,
      fechaRegistro: DateTime.parse(map['fecha_registro'] as String),
      sincronizado: map['sincronizado'] as int? ?? 0,
      usuarioId: map['Usuarios_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ee': ee,
      'proyecto': proyecto,
      'epp': epp,
      'locativa': locativa,
      'extintor_maquina': extintorMaquina,
      'rutinaria_maquina': rutinariaMaquina,
      'gestion_cumple': gestionCumple,
      'foto1': foto1,
      'foto2': foto2,
      'foto3': foto3,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'sincronizado': sincronizado,
      'Usuarios_id': usuarioId,
    };
  }

  GestionModel copyWith({
    int? id,
    String? ee,
    String? proyecto,
    String? epp,
    String? locativa,
    String? extintorMaquina,
    String? rutinariaMaquina,
    String? gestionCumple,
    String? foto1,
    String? foto2,
    String? foto3,
    DateTime? fechaRegistro,
    int? sincronizado,
    int? usuarioId,
  }) {
    return GestionModel(
      id: id ?? this.id,
      ee: ee ?? this.ee,
      proyecto: proyecto ?? this.proyecto,
      epp: epp ?? this.epp,
      locativa: locativa ?? this.locativa,
      extintorMaquina: extintorMaquina ?? this.extintorMaquina,
      rutinariaMaquina: rutinariaMaquina ?? this.rutinariaMaquina,
      gestionCumple: gestionCumple ?? this.gestionCumple,
      foto1: foto1 ?? this.foto1,
      foto2: foto2 ?? this.foto2,
      foto3: foto3 ?? this.foto3,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }
}
