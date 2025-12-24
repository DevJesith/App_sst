import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/actualizar_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/crear_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/eliminar_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/get_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/get_maestros_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/presentation/states/enfermedad_states.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EnfermedadNotifier extends StateNotifier<EnfermedadStates> {
  final CrearEnfermedadUsecases crearEnfermedadUsecases;
  final GetEnfermedadUsecases getEnfermedadUsecases;
  final ActualizarEnfermedadUsecases actualizarEnfermedadUsecases;
  final EliminarEnfermedadUsecases eliminarEnfermedadUsecases;

  EnfermedadNotifier({
    required this.getEnfermedadUsecases,
    required this.crearEnfermedadUsecases,
    required this.actualizarEnfermedadUsecases,
    required this.eliminarEnfermedadUsecases,
  }) : super(const EnfermedadStates());

  //Cargar todos enfermedad
  Future<void> loadEnfermedad() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final enfermedad = await getEnfermedadUsecases();
      state = state.copyWith(enfermedad: enfermedad, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar Enfermedad',
      );
    }
  }

  //Crear nueva enfermedad
  Future<bool> crearEnfermedad(Enfermedad enfermedad) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await crearEnfermedadUsecases(enfermedad);
      state = state.copyWith(isSubmitting: false);
      await loadEnfermedad();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al crear enfermedad: $e',
      );
      return false;
    }
  }

  //Actualizar enfermedad existente
  Future<bool> actualizarEnfermedad(Enfermedad enfermedad) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await actualizarEnfermedadUsecases(enfermedad);
      state = state.copyWith(isSubmitting: false);
      await loadEnfermedad();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al actualizar enfermedad: $e',
      );
      return false;
    }
  }

  //Eliminar enfermedad
  Future<bool> eliminarEnfermedad(int id) async {
    try {
      await eliminarEnfermedadUsecases(id);
      await loadEnfermedad();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar enfermedad: $e');
      return false;
    }
  }

  //Eliminar mensaje de error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

class EnfermedadFormNotifier extends StateNotifier<EnfermedadFormState> {

  final GetProyectosEnfermedadUseCase getProyectosUseCase;
  final GetContratistasEnfermedadesUseCase getContratistasUseCase;
  final GetTrabajadoresEnfermedadUseCase getTrabajadoresUseCase;

  EnfermedadFormNotifier({
    required this.getProyectosUseCase,
    required this.getContratistasUseCase,
    required this.getTrabajadoresUseCase
  }) : super(const EnfermedadFormState()){
    _cargarProyectos();
  }

  Future<void> _cargarProyectos() async {
    try {
      final proyectos = await getProyectosUseCase();
      state = state.copyWith(listaProyectos: proyectos);
    } catch (e) {
      print("Error cargando proyectos: $e");
    }
  }

  void setProyectoId(int? id) async {
    if (id == null) return;

    state = EnfermedadFormState(
      proyectoId: id,
      contratistaId: null,
      trabajadorId: null,
      estado: state.estado,
      fecha: state.fecha,
      listaProyectos: state.listaProyectos,
      listaContratista: [],
      listaTrabajadores: [],
    );

    try {
      final contratistas = await getContratistasUseCase(id);
      state = state.copyWith(listaContratista: contratistas);
    } catch (e) {
      print("Error cargando contratistas: $e");
    }
  }

  void setContratistaId(int? id) async {
    if (id == null || state.proyectoId == null) return;

    // Reiniciar trabajador
    state = state.copyWith(
      contratistaId: id,
      trabajadorId: null, // Forzar null
      listaTrabajadores: [], // Limpiar
    );

    try {
      final trabajadores = await getTrabajadoresUseCase(state.proyectoId!, id);
      state = state.copyWith(listaTrabajadores: trabajadores);
    } catch (e) {
      print("Error cargando trabajadores: $e");
    }
  }

  void setTrabajadorId(int? id) {
    state = state.copyWith(trabajadorId: id);
  }

  void setEstado(String? value) {
    state = state.copyWith(estado: value);
  }

  void setFecha(DateTime? value) {
    state = state.copyWith(fecha: value);
  }

  void reset() {
    state = EnfermedadFormState(listaProyectos: state.listaProyectos);
  }
}
