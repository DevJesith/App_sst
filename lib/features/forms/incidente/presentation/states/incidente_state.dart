import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';

/// Estado global del modulo
/// 
/// Gestiona la informacion de la vista de lista (CRUD):
/// * [incidentes]: La lista de reportes cargados.
/// * [isLoading]: Si se esta consultando la base de datos.
/// * [errorMessage]: Si ocurrio un error.
/// * [isSubmitting]: Si se esta guardando/eliminando un registro
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

/// Estado especifico del formulario
/// 
/// Gestiona: 
/// 1. El proyecto seleccionado (ID).
/// 2. La lista maestra de proyectos para el Dropdown
/// 3. Otros campos temporales
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
