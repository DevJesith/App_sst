

class Gestion {
  final int? id;
  final String ee;
  final int proyectoId;
  final String epp;
  final String locativa;
  final String extintorMaquina;
  final String rutinariaMaquina;
  final String gestionCumple;
  final String foto1;
  final String foto2;
  final String foto3;
  final DateTime fechaRegistro;
  final int sincronizado;
  final int usuarioId;

  const Gestion({
    this.id,
    required this.ee,
    required this.proyectoId,
    required this.epp,
    required this.locativa,
    required this.extintorMaquina,
    required this.rutinariaMaquina,
    required this.gestionCumple,
    required this.foto1,
    required this.foto2,
    required this.foto3,
    required this.fechaRegistro,
    this.sincronizado = 0,
    required this.usuarioId,

  });

}