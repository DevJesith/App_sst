
import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';

class AccidenteState {
  final List<Accidente> accidentes;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitting;

  const AccidenteState({
    this.accidentes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  AccidenteState copyWith({
    List<Accidente>? accidentes,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return AccidenteState(
      accidentes: accidentes ?? this.accidentes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Estado del formulario de accidente (valores de los campos)
class AccidenteFormState {
  final String? proyecto;
  final String? estado;
  final DateTime? fecha;

  const AccidenteFormState({
    this.proyecto,
    this.estado,
    this.fecha
  });

  AccidenteFormState copyWith({
    String? proyecto,
    String? estado,
    DateTime? fecha,
  }) {
    return AccidenteFormState(
      proyecto: proyecto ?? this.proyecto,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
    );
  }
}