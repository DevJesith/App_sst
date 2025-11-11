import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';

class EnfermedadStates {
  final List<Enfermedad> enfermedad;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitting;

  const EnfermedadStates({
    this.enfermedad = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  EnfermedadStates copyWith({
    List<Enfermedad>? enfermedad,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return EnfermedadStates(
      enfermedad: enfermedad ?? this.enfermedad,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class EnfermedadFormState {
  final String? proyecto;
  final String? estado;
  final String? contratista;
  final DateTime? fecha;

  const EnfermedadFormState({this.proyecto, this.estado, this.contratista, this.fecha});

  EnfermedadFormState copyWith({
    String? proyecto,
    String? estado,
    String? contratista,
    DateTime? fecha,
  }) {
    return EnfermedadFormState(
      proyecto: proyecto ?? this.proyecto,
      estado: estado ?? this.estado,
      contratista: contratista ?? this.contratista,
      fecha: fecha ?? this.fecha,
    );
  }
}
