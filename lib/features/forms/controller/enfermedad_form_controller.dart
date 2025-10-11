import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:flutter/material.dart';
import 'package:app_sst/features/forms/state/enfermedad_form_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Controlador para el formulario de capacitación.
/// Maneja estado reactivo y lógica de envío.
class EnfermedadFormController extends StateNotifier<EnfermedadFormState> {
  EnfermedadFormController() : super(EnfermedadFormState());

  final formKey = GlobalKey<FormState>();

  void setProyecto(String? value) {
    state = state.copyWith(proyecto: value);
  }

  void setContratista(String? value) {
    state = state.copyWith(contratista: value);
  }

  void setEstado(String? value) {
    state = state.copyWith(estado: value);
  }

  void setFecha(DateTime? nuevaFecha) {
    state = state.copyWith(fecha: nuevaFecha);
  }

  /// Envía el formulario si es válido, limpia campos y muestra confirmación.
  void sendForm({
    required BuildContext context,
    required WidgetRef ref,
    required VoidCallback onSuccess,
    required List<TextEditingController> controllersClear,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      ref.invalidate(enfermedadFormProvider);

      for (final controller in controllersClear) {
        controller.clear();
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Formulario enviando'),
          content: Text('Formulario exitoso'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onSuccess();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
