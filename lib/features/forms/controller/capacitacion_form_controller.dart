import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:app_sst/features/forms/state/capacitacion_form_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Controlador para el formulario de capacitación.
/// Maneja estado reactivo y lógica de envío.

class CapacitacionFormController extends StateNotifier<CapacitacionFormState> {
  CapacitacionFormController() : super(CapacitacionFormState());

  final formKey = GlobalKey<FormState>();

  void setProyecto(String? value) {
    state = state.copyWith(proyecto: value);
  }

  void setContratista(String? value) {
    state = state.copyWith(contratista: value);
  }

  /// Envía el formulario si es válido, limpia campos y muestra confirmación.
  void sendForm({
    required BuildContext context,
    required WidgetRef ref,
    required VoidCallback onSuccess,
    required List<TextEditingController> controllersClear,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      ref.invalidate(capacitacionFormProvider);

      for (final controller in controllersClear) {
        controller.clear();
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Formulario enviado'),
        content: Text('Completado con exito'),
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
