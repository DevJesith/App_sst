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
  final int? proyectoId;
  final String? estado;
  final DateTime? fecha;
  final List<Map<String, dynamic>> listaProyectos;

  const IncidenteFormState({this.proyectoId, this.estado, this.fecha, this.listaProyectos = const []});

  IncidenteFormState copyWith({
    int? proyectoId,
    String? estado,
    DateTime? fecha,
    List<Map<String, dynamic>>? listaProyectos,
  }) {
    return IncidenteFormState(
      proyectoId: proyectoId ?? this.proyectoId,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      listaProyectos: listaProyectos ?? this.listaProyectos
    );
  }
}
