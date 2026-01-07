import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/actualizar_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/crear_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/eliminar_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/get_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/domain/usecases/get_maestros_incidente_usecases.dart';
import 'package:app_sst/features/forms/incidente/presentation/states/incidente_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Notifier encargado de la gestion de la lsita de incidentes (CRUD).
/// 
/// Maneja los estados de carga, exito y error al interactuar con la base de datos.
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

  /// Carga la lista completa de incidentes dedsde la base de datos
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

  /// Crea un nuevo registro de incidente.
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

  /// Actualiza un incidente existente.
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

  /// Elimina un incidente por su ID.
  Future<bool> eliminarIncidente(int id) async {
    try {
      await eliminarIncidenteUsecases(id);
      await loadIncidentes();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar incidente: $e ');
      return false;
    }
  }

  /// Limpia los mensajes de error del estado
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Notifier para el estado del formulario
/// 
/// Maneja: 
/// 1. La carga de la lista de proyectos
/// 2. La seleccion del proyecto y otros campos.
class IncidenteFormNotifier extends StateNotifier<IncidenteFormState> {

  final GetProyectosIncidenteUseCase getProyectosUseCase;

  IncidenteFormNotifier({
    required this.getProyectosUseCase
  }) : super(const IncidenteFormState()){
    _cargarProyectos();
  }

  /// Carga la lista de proyectos disponibles desde la BD.
  Future<void> _cargarProyectos() async {
    try {
      print("🔄 INCIDENTE: Iniciando carga de proyectos...");
      final proyectos = await getProyectosUseCase();
      
      print("✅ INCIDENTE: Proyectos encontrados: ${proyectos.length}");
      
      if (proyectos.isEmpty) {
        print("⚠️ INCIDENTE: La lista de proyectos llegó vacía de la BD.");
      }

      state = state.copyWith(listaProyectos: proyectos);
    } catch (e) {
      print("❌ INCIDENTE ERROR: No se pudieron cargar los proyectos: $e");
    }
  }

  /// Metodo publico para forzar la recarga de proyectos si falla la inicial.
  Future<void> recargarProyectos() async {
    await _cargarProyectos();
  }

  /// Establece el ID del proyecto seleccionado.
  void setProyectoId(int? value) {
    state = state.copyWith(proyectoId: value);
  }

  void setEstado(String? value) {
    state = state.copyWith(estado: value);
  }

  void setFecha(DateTime? value) {
    state = state.copyWith(fecha: value);
  }

  /// Reinicia el formulario manteniendo la lista de proyectos cargada.
  void reset() {
    state = IncidenteFormState(listaProyectos: state.listaProyectos);
  }
}
