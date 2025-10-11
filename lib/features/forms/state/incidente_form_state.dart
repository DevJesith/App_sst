// Estado del formulario de incidente.
// Contiene los valores seleccionados para proyecto, estado y fecha.
// Es inmutable y se actualiza mediante `copyWith`.

class IncidenteFormState {
  final String? proyecto;
  final String? estado;
  final DateTime? fecha;

  const IncidenteFormState({this.proyecto, this.estado, this.fecha});

  /// Crea una nueva instancia con los valores actualizados.
  /// Permite mantener la inmutabilidad del estado.

  IncidenteFormState copyWith({
    String? proyecto,
    String? estado,
    DateTime? fecha,
  }) {
    return IncidenteFormState(
      proyecto: proyecto ?? this.proyecto,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
    );
  }
}
