import 'package:app_sst/features/forms/capacitacion/domain/usecases/actualizar_capacitacion_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/create_capacitacion_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/eliminar_capacitacion_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/get_capacitaciones_usecases.dart';
import 'package:app_sst/features/forms/capacitacion/domain/usecases/get_maestros_capacitacion_usecases.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/capacitacion.dart';

import '../states/capacitacion_state.dart';

/// Notifier encargando de la gestion de la lista de capacitaciones (CRUD)
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

  /// Carga todas las capacitaciones desde la BD local.
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

  /// Crea una nueva capacitacion y recarga la lista.
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

  /// Actualiza una capacitacion existente
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

  /// Elimina una capacitacion por ID.
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

/// Notifier para el estado del formulario
/// Maneja la seleccion de Proyecto y la carga en cascada de Contratistas.
class CapacitacionFormNotifier extends StateNotifier<CapacitacionFormState> {

  final GetProyectosCapacitacionUseCase getProyectosUseCase;
  final GetContratistasCapacitacionUseCase getContratistasUseCase;

  CapacitacionFormNotifier({
    required this.getProyectosUseCase,
    required this.getContratistasUseCase
  }) : super(const CapacitacionFormState()){
    _cargarProyectos();
  }

  /// Carga la lista inicial de proyectos
  Future<void> _cargarProyectos() async {
    final proyectos = await getProyectosUseCase();
    state = state.copyWith(listaProyectos: proyectos);
  }

  /// Selecciona un proyecto y carga sus contratistas asociados.
  void setIdProyecto(int? proyectoId) async {
    if (proyectoId == null) return;

    // 1. Reiniciar estado (Contratista NULL) sin usar copyWith para evitar errores
    // Mantenemos la lista de proyectos cargada.
    state = CapacitacionFormState(
      idProyecto: proyectoId,
      idContratista: null, // Forzamos null
      listaProyectos: state.listaProyectos,
      listaContratistas: [], // Limpiamos lista de contratistas
    );

    // 2. Cargar contratistas de este proyecto
    try {
      final contratistas = await getContratistasUseCase(proyectoId);
      state = state.copyWith(listaContratistas: contratistas);
    } catch (e) {
      print("Error cargando contratistas: $e");
    }
  }

  void setIdContratista(int? value) {
    state = state.copyWith(idContratista: value);
  }

  /// Reinicia el formulario pero mantiene los proyectos cargados.
  void reset() {
    state = CapacitacionFormState(listaProyectos: state.listaProyectos);
  }
}