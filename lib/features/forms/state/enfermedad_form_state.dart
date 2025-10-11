// Estado del formulario de enfermedad laboral.
// Contiene proyecto, contratista, estado y fecha.

class EnfermedadFormState {
  final String? proyecto;
  final String? contratista;
  final String? estado;
  final DateTime? fecha;

  const EnfermedadFormState({
    this.proyecto,
    this.contratista,
    this.estado,
    this.fecha,
  });

  /// Crea una nueva instancia con los valores actualizados.

  EnfermedadFormState copyWith({
    String? proyecto,
    String? contratista,
    String? estado,
    DateTime? fecha,
  }) {
    return EnfermedadFormState(
      proyecto: proyecto ?? this.proyecto,
      contratista: contratista ?? this.contratista,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
    );
  }
}
