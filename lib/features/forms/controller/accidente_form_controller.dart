import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../state/accidente_form_state.dart';

// Este controlador maneja la lógica del formulario de accidente.
// Extiende StateNotifier para manejar el estado reactivo del formulario.

class AccidenteFormController extends StateNotifier<AccidenteFormState> {
  AccidenteFormController() : super(const AccidenteFormState());

  // Clave global del formulario, usada para validar los campos
  final formKey = GlobalKey<FormState>();

  // Método para actualizar el valor del dropdown de proyecto
  void setProyecto(String? value) {
    state = state.copyWith(proyecto: value);
  }

  // Método para actualizar el valor del dropdown de estado
  void setEstado(String? value) {
    state = state.copyWith(estado: value);
  }

  //Metodo para actualizar el valor de la fecha
  void setFecha(DateTime? nuevaFecha){
    state = state.copyWith(fecha: nuevaFecha);
  }

  // Método para enviar el formulario
  // - Valida los campos
  // - Limpia el estado de Riverpod
  // - Limpia los campos de texto
  // - Muestra un diálogo de confirmación

  void sendForm({
    required BuildContext context,
    required WidgetRef ref,
    required VoidCallback onSuccess,
    required List<TextEditingController> controllersClear,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      // Reiniciamos el estado de Riverpod (proyecto y estado)
      ref.invalidate(accidenteFormProvider);

      // Limpiamos todos los campos de texto

      for (final controller in controllersClear) {
        controller.clear();
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Fomrulario enviado"),
          content: Text("Completado con exito"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onSuccess();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}
