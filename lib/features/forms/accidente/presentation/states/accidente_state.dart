
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
  final String? contratista;
  final String? estado;
  final DateTime? fecha;
  final List<Map<String, dynamic>> listaProyectos;
  final List<Map<String, dynamic>> listaContratistas;

  const AccidenteFormState({
    this.proyecto,
    this.contratista,
    this.estado,
    this.fecha,
    this.listaProyectos = const [],
    this.listaContratistas = const []
  });

  AccidenteFormState copyWith({
    String? proyecto,
    String? contratista,
    String? estado,
    DateTime? fecha,
    List<Map<String, dynamic>>? listaProyectos,
    List<Map<String, dynamic>>? listaContratistas,
  }) {
    return AccidenteFormState(
      proyecto: proyecto ?? this.proyecto,
      contratista: contratista ?? this.contratista,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      listaProyectos: listaProyectos ?? this.listaProyectos,
      listaContratistas: listaContratistas ?? this.listaContratistas
    );
  }
}