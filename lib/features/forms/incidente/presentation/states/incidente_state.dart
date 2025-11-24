import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';

class IncidenteState {
  final List<Incidente> incidentes;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitting;

  const IncidenteState({
    this.incidentes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  IncidenteState copyWith({
    List<Incidente>? incidentes,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return IncidenteState(
      incidentes: incidentes ?? this.incidentes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class IncidenteFormState {
  final String? proyecto;
  final String? estado;
  final DateTime? fecha;

  const IncidenteFormState({this.proyecto, this.estado, this.fecha});

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
