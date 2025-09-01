class IncidenteFormState {
  final String? proyecto;
  final String? estado;
  final DateTime? fecha;

  const IncidenteFormState({this.proyecto, this.estado, this.fecha});

  IncidenteFormState copyWith({String? proyecto, String? estado, DateTime? fecha}){
    return IncidenteFormState(
      proyecto: proyecto ?? this.proyecto,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha
    );
  }
}