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
  final int? proyectoId;
  final int? contratistaId;
  final int? trabajadorId;
  final String? estado;
  final DateTime? fecha;
  final List<Map<String, dynamic>> listaProyectos;
  final List<Map<String, dynamic>> listaContratista;
  final List<Map<String, dynamic>> listaTrabajadores;

  const EnfermedadFormState({
    this.proyectoId,
    this.contratistaId,
    this.trabajadorId,
    this.estado,
    this.fecha,
    this.listaProyectos = const [],
    this.listaContratista = const [],
    this.listaTrabajadores = const [],
  });

  EnfermedadFormState copyWith({
    int? proyectoId,
    int? contratistaId,
    int? trabajadorId,
    String? estado,
    DateTime? fecha,
    List<Map<String, dynamic>>? listaProyectos,
    List<Map<String, dynamic>>? listaContratista,
    List<Map<String, dynamic>>? listaTrabajadores,
  }) {
    return EnfermedadFormState(
      proyectoId: proyectoId ?? this.proyectoId,
      contratistaId: contratistaId ?? this.contratistaId,
      trabajadorId: trabajadorId ?? this.trabajadorId,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      listaProyectos: listaProyectos ?? this.listaProyectos,
      listaContratista: listaContratista ?? this.listaContratista,
      listaTrabajadores: listaTrabajadores ?? this.listaTrabajadores
    );
  }
}
