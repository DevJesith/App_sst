import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/actualizar_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/crear_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/eliminar_enfermedad_usecases.dart';
import 'package:app_sst/features/forms/enfermedad/domain/usecases/get_enfermedad_usecases.dart';
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
  EnfermedadFormNotifier() : super(const EnfermedadFormState());

  void setProyecto(String? value) {
    state = state.copyWith(proyecto: value);
  }

  void setEstado(String? value) {
    state = state.copyWith(estado: value);
  }

  void setContratista(String? value) {
    state = state.copyWith(contratista: value);
  }

  void setFecha(DateTime? value) {
    state = state.copyWith(fecha: value);
  }

  void reset() {
    state = const EnfermedadFormState();
  }
}
