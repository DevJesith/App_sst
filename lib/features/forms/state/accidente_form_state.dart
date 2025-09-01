// Este archivo define el estado del formulario de accidente.
// Usamos una clase inmutable para representar los valores seleccionados en los dropdowns.

class AccidenteFormState {
  final String? proyecto;
  final String? estado;
  final DateTime? fecha;

  const AccidenteFormState({this.estado, this.proyecto, this.fecha});

  // Método para copiar el estado actual y actualizar solo los campos necesarios
  // Esto permite mantener la inmutabilidad y actualizar el estado de forma segura

  AccidenteFormState copyWith({String? proyecto, String? estado, DateTime? fecha}) {
    return AccidenteFormState(
      proyecto: proyecto ?? this.proyecto,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha
    );
  }
}
