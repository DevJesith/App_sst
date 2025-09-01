import 'package:app_sst/features/forms/controller/accidente_form_controller.dart';
import 'package:app_sst/features/forms/controller/capacitacion_form_controller.dart';
import 'package:app_sst/features/forms/controller/enfermedad_form_controller.dart';
import 'package:app_sst/features/forms/controller/gestion_form_controller.dart';
import 'package:app_sst/features/forms/controller/incidente_form_controller.dart';
import 'package:app_sst/features/forms/state/accidente_form_state.dart';
import 'package:app_sst/features/forms/state/capacitacion_form_state.dart';
import 'package:app_sst/features/forms/state/enfermedad_form_state.dart';
import 'package:app_sst/features/forms/state/gestion_form_state.dart';
import 'package:app_sst/features/forms/state/incidente_form_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Este archivo define el provider de Riverpod que conecta el controlador con el estado.
// Usamos StateNotifierProvider para manejar el estado reactivo del formulario.

final accidenteFormProvider =
    StateNotifierProvider<AccidenteFormController, AccidenteFormState>(
      (ref) => AccidenteFormController(),
    );

final capacitacionFormProvider =
    StateNotifierProvider<CapacitacionFormController, CapacitacionFormState>(
      (ref) => CapacitacionFormController(),
    );

final enfermedadFormProvider =
    StateNotifierProvider<EnfermedadFormController, EnfermedadFormState>(
      (ref) => EnfermedadFormController(),
    );

final incidenteFormProvider =
    StateNotifierProvider<IncidenteFormController, IncidenteFormState>(
      (ref) => IncidenteFormController(),
    );

final gestionFormProvider =
    StateNotifierProvider<GestionFormController, GestionFormState>(
      (ref) => GestionFormController(),
    );
