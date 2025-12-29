
import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';


/// Estado global para el modulo
/// 
/// Gestiona la informacion general como:
/// La lista de accidentes cargados.
/// Indicadores de cargar los loading.
/// Mensajes de error.
/// Estado de envio de formulario
class AccidenteState {

  /// Lista de accidentes recuperados de la BD
  final List<Accidente> accidentes;

  /// Indica si se esta cargando la lista inicial
  final bool isLoading;

  /// Mensaje de error si alguna operacion falla (null si no hay error)
  final String? errorMessage;

  /// Indica si se esta procesando un envio
  final bool isSubmitting;

  const AccidenteState({
    this.accidentes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  /// Crea una copia del estado con los campos modificados.
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

/// Estado especifico
/// 
/// Gestiona los valores temporales que el usuario selecciona en la pantalla
/// anes de guardar, asi como las listas dinamicas para los Dropdowns.
class AccidenteFormState {

  // campos del formulario
  final String? proyecto;
  final String? contratista;
  final String? estado;
  final DateTime? fecha;

  /// Lista completa de proyectos disponibles
  final List<Map<String, dynamic>> listaProyectos;

  /// Lista de contratistas filtrado segun el proyecto seleccionado
  final List<Map<String, dynamic>> listaContratistas;

  const AccidenteFormState({
    this.proyecto,
    this.contratista,
    this.estado,
    this.fecha,
    this.listaProyectos = const [],
    this.listaContratistas = const []
  });

  /// Crea un copia del estado del formulario
  /// Util para actualizar un solo campo sin perder los demas.
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