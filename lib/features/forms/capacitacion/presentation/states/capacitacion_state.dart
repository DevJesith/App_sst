// features/forms/capacitacion/presentation/states/capacitacion_state.dart

import '../../domain/entities/capacitacion.dart';

/// Estado global del modulo
/// 
/// Gestiona la informacion de la vista de lista (CRUD):
/// * [capacitaciones]: ls lista de registros cargados.
/// * [isLoading]: Si se esta consultando BD.
/// * [errorMessage]: Si se ocurrio un error.
/// * [isSubmitting]: Si se esta guardando/eliminando un registro
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

/// Estado especifico del formulario
/// 
/// Gestiona los valores seleccionados y las listas para los Dropdowns.
class CapacitacionFormState {
  final int? idProyecto;
  final int? idContratista;
  final List<Map<String, dynamic>> listaProyectos;
  final List<Map<String, dynamic>> listaContratistas;

  const CapacitacionFormState({
    this.idProyecto,
    this.idContratista,
    this.listaProyectos = const [],
    this.listaContratistas = const []
  });

  CapacitacionFormState copyWith({
    int? idProyecto,
    int? idContratista,
    List<Map<String, dynamic>>? listaProyectos,
    List<Map<String, dynamic>>? listaContratistas,
  }) {
    return CapacitacionFormState(
      idProyecto: idProyecto ?? this.idProyecto,
      idContratista: idContratista ?? this.idContratista,
      listaProyectos: listaProyectos ?? this.listaProyectos,
      listaContratistas: listaContratistas ?? this.listaContratistas,
    );
  }
}