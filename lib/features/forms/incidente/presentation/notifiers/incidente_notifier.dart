import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/actualizar_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/crear_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/eliminar_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/get_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/presentation/states/incidente_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class IncidenteNotifier extends StateNotifier<IncidenteState> {
  final CrearIncidenteUsecases crearIncidenteUsecases;
  final GetIncidenteUsecases getIncidenteUsecases;
  final ActualizarIncidenteUsecases actualizarIncidenteUsecases;
  final EliminarIncidenteUsecases eliminarIncidenteUsecases;

  IncidenteNotifier({
    required this.getIncidenteUsecases,
    required this.crearIncidenteUsecases,
    required this.actualizarIncidenteUsecases,
    required this.eliminarIncidenteUsecases,
  }) : super(const IncidenteState());

  //Cargar todos los incidentes
  Future<void> loadIncidentes() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final incidentes = await getIncidenteUsecases();
      state = state.copyWith(incidentes: incidentes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar incidentes: $e',
      );
    }
  }

  //Crear nuevo incidente
  Future<bool> crearIncidente(Incidente incidente) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await crearIncidenteUsecases(incidente);
      state = state.copyWith(isSubmitting: false);
      await loadIncidentes();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al crear incidente: $e',
      );
      return false;
    }
  }

  //Actualizar incidente existente
  Future<bool> actualizarIncidente(Incidente incidente) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await actualizarIncidenteUsecases(incidente);
      state = state.copyWith(isSubmitting: false);
      await loadIncidentes();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al actualizar incidente: $e',
      );
      return false;
    }
  }

  //Eliminar incidente
  Future<bool> eliminarIncidente(int id) async {
    try {
      await eliminarIncidente(id);
      await loadIncidentes();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar incidente: $e ');
      return false;
    }
  }

  //Limpiar mensaje de error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

class IncidenteFormNotifier extends StateNotifier<IncidenteFormState> {
  IncidenteFormNotifier() : super(const IncidenteFormState());

  void setProyecto(String? value) {
    state = state.copyWith(proyecto: value);
  }

  void setEstado(String? value) {
    state = state.copyWith(estado: value);
  }

  void setFecha(DateTime? value) {
    state = state.copyWith(fecha: value);
  }

  void reset() {
    state = const IncidenteFormState();
  }
}
