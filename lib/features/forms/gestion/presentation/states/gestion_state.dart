import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:image_picker/image_picker.dart';

/// Estado global del modulo
/// 
/// Gestiona la informacion de la vista de lista (CRUD):
/// * [gestiones]: La lista de reportes cargados.
/// * [isLoading]: Si se esta consultando la BD.
/// * [errorMessage]: Si ocurrio un error.
/// * [isSubmitting]: Si se esta guardando/eliminando un registro.
class GestionState {
  final List<Gestion> gestiones;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitting;

  const GestionState({
    this.gestiones = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  GestionState copyWith({
    List<Gestion>? gestiones,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return GestionState(
      gestiones: gestiones ?? this.gestiones,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting
    );
  }
}

/// Estado especifico del formulario.
/// 
/// Gestiona:
/// 1. La listade imagenes seleccionadas.
/// 2. El proyecto seleccionado
/// 3. La lista de maestra de proyectos para el Dropdown.
class GestionFormState {
  /// Lista de imagenes seleccionadas (Camara o Galeria)
  final List<XFile> imagenes;

  /// ID del proyecto seleccionado.
  final int? proyectoId;

  final DateTime? fecha;

  /// Lista de proyectos cargados desde la BD para el Dropdown.
  final List<Map<String, dynamic>> listaProyectos;

  const GestionFormState({
    this.imagenes = const [],
    this.proyectoId,
    this.fecha,
    this.listaProyectos = const []
  });

  GestionFormState copyWith ({
    List<XFile>? imagenes,
    int? proyectoId,
    DateTime? fecha,
    List<Map<String, dynamic>>? listaProyectos,
  }){
    return GestionFormState(
      imagenes: imagenes ?? this.imagenes,
      proyectoId: proyectoId ?? this.proyectoId,
      fecha: fecha ?? this.fecha,
      listaProyectos: listaProyectos ?? this.listaProyectos
    );
  }
}