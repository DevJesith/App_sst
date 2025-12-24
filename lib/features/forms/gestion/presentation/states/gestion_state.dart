
import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:image_picker/image_picker.dart';

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

class GestionFormState {
  final List<XFile> imagenes;
  final int? proyectoId;
  final List<Map<String, dynamic>> listaProyectos;

  const GestionFormState({
    this.imagenes = const [],
    this.proyectoId,
    this.listaProyectos = const []
  });

  GestionFormState copyWith ({
    List<XFile>? imagenes,
    int? proyectoId,
    List<Map<String, dynamic>>? listaProyectos,
  }){
    return GestionFormState(
      imagenes: imagenes ?? this.imagenes,
      proyectoId: proyectoId ?? this.proyectoId,
      listaProyectos: listaProyectos ?? this.listaProyectos
    );
  }
}