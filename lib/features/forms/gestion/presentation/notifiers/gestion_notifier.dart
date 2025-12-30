import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/domain/usecases/actualizar_gestion_usecases.dart';
import 'package:app_sst/features/forms/gestion/domain/usecases/crear_gestion_usecases.dart';
import 'package:app_sst/features/forms/gestion/domain/usecases/eliminar_gestion_usecases.dart';
import 'package:app_sst/features/forms/gestion/domain/usecases/get_gestion_usecases.dart';
import 'package:app_sst/features/forms/gestion/domain/usecases/get_maestros_gestion_usecases.dart';
import 'package:app_sst/features/forms/gestion/presentation/states/gestion_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Notifier encargado de la gestion de la lista de reportes.
class GestionNotifier extends StateNotifier<GestionState> {
  final GetGestionUsecases getGestionUsecases;
  final CrearGestionUsecases crearGestionUsecases;
  final ActualizarGestionUsecases actualizarGestionUsecases;
  final EliminarGestionUsecases eliminarGestionUsecases;

  GestionNotifier({
    required this.getGestionUsecases,
    required this.crearGestionUsecases,
    required this.actualizarGestionUsecases,
    required this.eliminarGestionUsecases,
  }) : super(const GestionState());

  //Carga todas las gestiones registradas.
  Future<void> loadGestiones() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final gestiones = await getGestionUsecases();
      state = state.copyWith(gestiones: gestiones, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar gestiones: $e',
      );
    }
  }

  //Crea un nuevo reporte.
  Future<bool> crearGestion(Gestion gestion) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await crearGestionUsecases(gestion);
      state = state.copyWith(isSubmitting: false);
      await loadGestiones();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al crear geestion: $e',
      );
      return false;
    }
  }

  /// Actualiza un reporte existente.
  Future<bool> actualizarGestion(Gestion gestion) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await actualizarGestionUsecases(gestion);
      state = state.copyWith(isSubmitting: false);
      await loadGestiones();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al actualizar gestion: $e',
      );
      return false;
    }
  }

  // Elimina un reporte por su ID.
  Future<bool> eliminarGestion(int id) async {
    try {
      await eliminarGestionUsecases(id);
      await loadGestiones();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar gestion: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Notifier para el estado del formulario.
///
/// Maneja:
/// 1. Seleccion de Proyecto.
/// 2. Manejo de Imagenes
class GestionFormNotifier extends StateNotifier<GestionFormState> {
  final GetProyectosGestionUseCase getProyectosUseCase;

  GestionFormNotifier({required this.getProyectosUseCase})
    : super(const GestionFormState()) {
    _cargarProyectos();
  }

  /// Carga la lista de proyectos disponibles para el dropdown
  Future<void> _cargarProyectos() async {
    try {
      final proyectos = await getProyectosUseCase();
      state = state.copyWith(listaProyectos: proyectos);
    } catch (e) {
      // En produccion usar logger
      print("Error cargando proyectos: $e");
    }
  }

  /// Actualiza el ID del proyecto seleccionado.
  void setProyectos(int? id) {
    state = state.copyWith(proyectoId: id);
  }

  /// Reemplaza la lista completa de imagenes.
  void setImagenes(List<XFile> nuevas) {
    state = state.copyWith(imagenes: nuevas);
  }

  /// Agrega una imagen a la lista maximo 3
  void agregarImagen(XFile imagen) {
    if (state.imagenes.length < 3) {
      final nuevasImagenes = List<XFile>.from(state.imagenes)..add(imagen);
      state = state.copyWith(imagenes: nuevasImagenes);
    }
  }

  /// Elimina una imagen por su indice.
  void eliminarImagen(int index) {
    final nuevasImagenes = List<XFile>.from(state.imagenes)..remove(index);
    state = state.copyWith(imagenes: nuevasImagenes);
  }

  /// Limpia todas las imagenes seleccionadas.
  void clearImagenes() {
    state = state.copyWith(imagenes: []);
  }

  /// Reinicia el formulario manteniendo los proyectos cargados.
  void reset() {
    state = GestionFormState(listaProyectos: state.listaProyectos);
  }
}
