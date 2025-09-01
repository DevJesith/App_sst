class CapacitacionFormState {
  final String? proyecto;
  final String? contratista;

  const CapacitacionFormState({this.proyecto, this.contratista});

  CapacitacionFormState copyWith({String? proyecto, String? contratista}) {
    return CapacitacionFormState(
      proyecto: proyecto ?? this.proyecto,
      contratista: contratista ?? this.contratista,
    );
  }
}
