import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:app_sst/features/forms/state/gestion_form_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class GestionFormController extends StateNotifier<GestionFormState> {
  GestionFormController() : super(GestionFormState());

  final formKey = GlobalKey<FormState>();

  void setProyecto(String? value) {
    state = state.copyWith(proyecto: value);
  }

  void setImagenes(List<XFile> nuevas) {
    state = state.copyWith(imagenes: nuevas);
  }

  void clearImagenes() {
    state = state.copyWith(imagenes: []);
  }

  void sendForm({
    required BuildContext context,
    required WidgetRef ref,
    required VoidCallback onSuccess,
    required List<TextEditingController> controllersClear,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      if (state.imagenes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debes subir al menos una foto')),
        );
        return;
      }

      ref.invalidate(gestionFormProvider);

      for (final controller in controllersClear) {
        controller.clear();
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Formulario enviado'),
          content: Text('Se envio el formulario con exito'),
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
