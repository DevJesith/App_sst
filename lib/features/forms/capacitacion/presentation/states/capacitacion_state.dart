// features/forms/capacitacion/presentation/states/capacitacion_state.dart

import '../../domain/entities/capacitacion.dart';

/// Estado del módulo de capacitaciones
class CapacitacionState {
  final List<Capacitacion> capacitaciones;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitting;

  const CapacitacionState({
    this.capacitaciones = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  CapacitacionState copyWith({
    List<Capacitacion>? capacitaciones,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return CapacitacionState(
      capacitaciones: capacitaciones ?? this.capacitaciones,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Estado del formulario de capacitación
class CapacitacionFormState {
  final int? idProyecto;
  final int? idContratista;

  const CapacitacionFormState({
    this.idProyecto,
    this.idContratista,
  });

  CapacitacionFormState copyWith({
    int? idProyecto,
    int? idContratista,
  }) {
    return CapacitacionFormState(
      idProyecto: idProyecto ?? this.idProyecto,
      idContratista: idContratista ?? this.idContratista,
    );
  }
}