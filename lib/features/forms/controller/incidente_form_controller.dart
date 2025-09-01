import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:app_sst/features/forms/state/incidente_form_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class IncidenteFormController extends StateNotifier<IncidenteFormState> {
  IncidenteFormController() : super(IncidenteFormState());

  final formKey = GlobalKey<FormState>();

  void setProyecto(String? value) {
    state = state.copyWith(proyecto: value);
  }

  void setEstado(String? value) {
    state = state.copyWith(estado: value);
  }

  void setFecha(DateTime? nuevaFecha){
    state = state.copyWith(fecha: nuevaFecha);
  }

  void sendForm({
    required BuildContext context,
    required WidgetRef ref,
    required VoidCallback onSuccess,
    required List<TextEditingController> controllersClear,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      ref.invalidate(incidenteFormProvider);

      for (final controller in controllersClear) {
        controller.clear();
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Fomrulario Enviado'),
          content: Text('Formulario enviado exitoso'),
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
