// Estado del formulario de capacitación.
// Contiene los valores seleccionados para proyecto y contratista.

class CapacitacionFormState {
  final String? proyecto;
  final String? contratista;

  const CapacitacionFormState({this.proyecto, this.contratista});

  /// Crea una nueva instancia con los valores actualizados.

  CapacitacionFormState copyWith({String? proyecto, String? contratista}) {
    return CapacitacionFormState(
      proyecto: proyecto ?? this.proyecto,
      contratista: contratista ?? this.contratista,
    );
  }
}
