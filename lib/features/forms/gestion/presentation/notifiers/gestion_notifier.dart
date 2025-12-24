
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

  //Cargar todas las gestiones
  Future<void> loadGestiones() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final gestiones = await getGestionUsecases();
      state = state.copyWith(
        gestiones: gestiones,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar gestiones: $e'
      );
    }
  }

  //Crear nueva gestion
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
        errorMessage: 'Error al crear geestion: $e'
      );
      return false;
    }
  }

  //Actualizar gestion
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
        errorMessage: 'Error al actualizar gestion: $e'
      );
      return false;
    }
  }

  //Eliminar gestion
  Future<bool> eliminarGestion(int id) async {
    try {
      await eliminarGestionUsecases(id);
      await loadGestiones();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al eliminar gestion: $e'
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

class GestionFormNotifier extends StateNotifier<GestionFormState> {

  final GetProyectosGestionUseCase getProyectosUseCase;

  GestionFormNotifier({
    required this.getProyectosUseCase
  }) : super(const GestionFormState()){
    _cargarProyectos();
  }

  Future<void> _cargarProyectos() async {
    final proyectos = await getProyectosUseCase();
    state = state.copyWith(listaProyectos: proyectos);
  }

  void setProyectos(int? id) {
    state = state.copyWith(proyectoId: id);
  }
  
  void setImagenes(List<XFile> nuevas) {
    state = state.copyWith(imagenes: nuevas);
  }

  void agregarImagen(XFile imagen) {
    if (state.imagenes.length < 3) {
      final nuevasImagenes = List<XFile>.from(state.imagenes)..add(imagen);
      state = state.copyWith(imagenes: nuevasImagenes);
    }
  }

  void eliminarImagen(int index) {
    final nuevasImagenes = List<XFile>.from(state.imagenes)..remove(index);
    state = state.copyWith(imagenes: nuevasImagenes);
  }

  void clearImagenes() {
    state = state.copyWith(imagenes: []);
  }

  void reset() {
    state = GestionFormState(listaProyectos: state.listaProyectos);
  }
}