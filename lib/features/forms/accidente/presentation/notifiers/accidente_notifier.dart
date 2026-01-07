import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/actualizar_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/crear_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/eliminar_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/get_accidentes_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/get_maestros_usecases.dart';
import 'package:app_sst/features/forms/accidente/presentation/states/accidente_state.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


/// Notifier encargado de la gestion de la lista de accidentes y operaciones CRUD
/// 
/// Maneja los estados de carga, exito y error al interactuar con la BD.
class AccidenteNotifier extends StateNotifier<AccidenteState> {
  final GetAccidentesUsecases getAccidentesUsecases;
  final CrearAccidenteUsecases crearAccidenteUsecases;
  final ActualizarAccidenteUsecases actualizarAccidenteUsecases;
  final EliminarAccidenteUsecases eliminarAccidenteUsecases;

  AccidenteNotifier({
    required this.getAccidentesUsecases,
    required this.crearAccidenteUsecases,
    required this.actualizarAccidenteUsecases,
    required this.eliminarAccidenteUsecases,
  }) : super(const AccidenteState());

  //Carga la lista completa de accidentes desde la BD
  Future<void> loadAccidentes() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final accidentes = await getAccidentesUsecases();
      state = state.copyWith(accidentes: accidentes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar accidentes: $e',
      );
    }
  }

  /// Crear nuevo accidente
  /// Retorna true si la operacion fue exitosa.
  Future<bool> crearAccidente(Accidente accidente) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await crearAccidenteUsecases(accidente);
      state = state.copyWith(isSubmitting: false);
      await loadAccidentes(); //Recargar lista
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al crear accidente: $e',
      );
      return false;
    }
  }

  //Actualizar accidente exisstente
  Future<bool> actualizarAccidente(Accidente accidente) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await actualizarAccidenteUsecases(accidente);
      state = state.copyWith(isSubmitting: false);
      await loadAccidentes();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al actualizar accidente: $e',
      );
      return false;
    }
  }

  //Eliminar accidente por su ID
  Future<bool> eliminarAccidente(int id) async {
    try {
      await eliminarAccidenteUsecases(id);
      await loadAccidentes();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar accidente: $e');
      return false;
    }
  }

  // Limpiar mensaje de error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Notifier encargado del estado del formulario
/// 
/// Maneja:
/// 1. Los valores seleccionados en los campos
/// 2. La carga de listas desplegables
/// 3. La logica de cascada, al seleccionar un proyecto se carga los contratistas

class AccidenteFormNotifier extends StateNotifier<AccidenteFormState> {
  final GetProyectosUseCase getProyectosUseCase;
  final GetContratistasPorProyectoUseCase getContratistasPorProyectoUseCase;

  AccidenteFormNotifier({
    required this.getProyectosUseCase,
    required this.getContratistasPorProyectoUseCase,
  }) : super(const AccidenteFormState()) {
    _cargarProyectosIniciales();
  }

  /// Carga la lsita inicial de proyectos disponibles
  Future<void> _cargarProyectosIniciales() async {
    final proyectos = await getProyectosUseCase();
    state = state.copyWith(listaProyectos: proyectos);
  }

  /// Selecciona un proyecto y carga sus contratistas asociados.
  /// 
  /// [id] : El id del proyecto sleecciona (String).nombreProyecto
  void setProyectoId(int? id) async {
    if (id == null) return;

    /// Creamos un estado nuevo para forzar que contratistas sea null.
    /// Esto evita erroes visuales en el Dropdown al cambiar de proyecto
    state = AccidenteFormState(
      proyectoId: id,
      contratistaId: null, // Se fuerza el null
      estado: state.estado,
      fecha: state.fecha,
      listaProyectos: state.listaProyectos,
      listaContratistas: [], // Limpiamos la lista temporalmente
    );

    try {
      // Cargamos los contratistas filtrados por ese ID
      final contratistas = await getContratistasPorProyectoUseCase(id);
      state = state.copyWith(listaContratistas: contratistas);
      
    } catch (e) {
      debugPrint("Error cargando contratistas: $e");
    }
  }

  void setContratistaId(int? value) {
    state = state.copyWith(contratistaId: value);
  }

  void setEstado(String? value) {
    state = state.copyWith(estado: value);
  }

  void setFecha(DateTime? value) {
    state = state.copyWith(fecha: value);
  }

  /// Reinicia el formulario a su estado inicial, mateniendo los proyectos cargados.
  void reset() {
    state = AccidenteFormState(listaProyectos: state.listaProyectos);
  }
}
