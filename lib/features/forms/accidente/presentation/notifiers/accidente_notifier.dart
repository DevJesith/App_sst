import 'package:app_sst/features/forms/accidente/domain/entities/accidente.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/actualizar_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/crear_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/eliminar_accidente_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/get_accidentes_usecases.dart';
import 'package:app_sst/features/forms/accidente/domain/usecases/get_maestros_usecases.dart';
import 'package:app_sst/features/forms/accidente/presentation/states/accidente_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  //Cargar todos los accidentes
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

  //Crear nuevo accidente
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

  //Eliminar accidente
  Future<bool> eliminarAccidente(int id) async {
    try {
      await eliminarAccidente(id);
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

class AccidenteFormNotifier extends StateNotifier<AccidenteFormState> {
  final GetProyectosUseCase getProyectosUseCase;
  final GetContratistasPorProyectoUseCase getContratistasPorProyectoUseCase;

  AccidenteFormNotifier({
    required this.getProyectosUseCase,
    required this.getContratistasPorProyectoUseCase,
  }) : super(const AccidenteFormState()) {
    _cargarProyectosIniciales();
  }

  Future<void> _cargarProyectosIniciales() async {
    final proyectos = await getProyectosUseCase();
    state = state.copyWith(listaProyectos: proyectos);
  }

  void setProyecto(String? nombreProyecto) async {
    if (nombreProyecto == null) return;

    // ⚠️ CAMBIO IMPORTANTE:
    // No usamos copyWith. Creamos un estado NUEVO para forzar que contratista sea NULL.
    state = AccidenteFormState(
      proyecto: nombreProyecto,
      contratista: null, // ✅ Ahora sí se fuerza el null
      estado: state.estado,
      fecha: state.fecha,
      listaProyectos: state.listaProyectos,
      listaContratistas: [], // Limpiamos la lista temporalmente
    );

    try {
      final proyectoObj = state.listaProyectos.firstWhere(
        (p) => (p['Nombre'] ?? p['nombre']) == nombreProyecto,
        orElse: () => {},
      );

      if (proyectoObj.isNotEmpty) {
        final proyectoId = proyectoObj['id'] as int;

        final contratistas = await getContratistasPorProyectoUseCase(proyectoId);

        // Aquí sí podemos usar copyWith porque estamos AGREGANDO datos, no borrando
        state = state.copyWith(listaContratistas: contratistas);
      }
      
    } catch (e) {
      print("Error cargando contratistas: $e");
    }
  }

  void setContratista(String? value) {
    state = state.copyWith(contratista: value);
  }

  void setEstado(String? value) {
    state = state.copyWith(estado: value);
  }

  void setFecha(DateTime? value) {
    state = state.copyWith(fecha: value);
  }

  void reset() {
    state = AccidenteFormState(listaProyectos: state.listaProyectos);
  }
}
