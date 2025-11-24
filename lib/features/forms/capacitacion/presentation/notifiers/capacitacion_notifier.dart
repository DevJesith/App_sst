// features/forms/capacitacion/presentation/notifiers/capacitacion_notifier.dart

import 'package:app_sst/features/forms/capacitacion/domain/usecases/actualizar_capacitacion_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/create_capacitacion_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/eliminar_capacitacion_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/get_capacitaciones_usecases.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/capacitacion.dart';

import '../states/capacitacion_state.dart';

class CapacitacionNotifier extends StateNotifier<CapacitacionState> {
  final GetCapacitacionesUsecases getCapacitacionesUseCase;
  final CreateCapacitacionUsecases createCapacitacionUseCase;
  final ActualizarCapacitacionUsecases actualizarCapacitacionUseCase;
  final EliminarCapacitacionUsecases eliminarCapacitacionUseCase;

  CapacitacionNotifier({
    required this.getCapacitacionesUseCase,
    required this.createCapacitacionUseCase,
    required this.actualizarCapacitacionUseCase,
    required this.eliminarCapacitacionUseCase,
  }) : super(const CapacitacionState());

  /// Cargar todas las capacitaciones
  Future<void> loadCapacitaciones() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final capacitaciones = await getCapacitacionesUseCase();
      state = state.copyWith(
        capacitaciones: capacitaciones,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar capacitaciones: $e',
      );
    }
  }

  /// Crear nueva capacitación
  Future<bool> createCapacitacion(Capacitacion capacitacion) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await createCapacitacionUseCase(capacitacion);
      state = state.copyWith(isSubmitting: false);
      await loadCapacitaciones();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al crear capacitación: $e',
      );
      return false;
    }
  }

  /// Actualizar capacitación
  Future<bool> updateCapacitacion(Capacitacion capacitacion) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await actualizarCapacitacionUseCase(capacitacion);
      state = state.copyWith(isSubmitting: false);
      await loadCapacitaciones();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al actualizar capacitación: $e',
      );
      return false;
    }
  }

  /// Eliminar capacitación
  Future<bool> deleteCapacitacion(int id) async {
    try {
      await eliminarCapacitacionUseCase(id);
      await loadCapacitaciones();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al eliminar capacitación: $e',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Notifier para el formulario (IDs de proyecto y contratista)
class CapacitacionFormNotifier extends StateNotifier<CapacitacionFormState> {
  CapacitacionFormNotifier() : super(const CapacitacionFormState());

  void setIdProyecto(int? value) {
    state = state.copyWith(idProyecto: value);
  }

  void setIdContratista(int? value) {
    state = state.copyWith(idContratista: value);
  }

  void reset() {
    state = const CapacitacionFormState();
  }
}