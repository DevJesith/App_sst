import 'package:app_sst/core/widgets/fecha_input_widgets.dart';
import 'package:app_sst/core/widgets/inputs_widgets.dart';
import 'package:app_sst/core/widgets/lista_input_wigets.dart';
import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class IncidenteForm extends HookConsumerWidget {
  const IncidenteForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(incidenteFormProvider.notifier);
    final state = ref.watch(incidenteFormProvider);

    //Controllers
    final eventualidadController = useTextEditingController();
    final descripcionController = useTextEditingController();
    final diasIncapacidadController = useTextEditingController();
    final avancesController = useTextEditingController();

    final proyecto = ["Proyecto 1", "Proyecto 2", "Proyecto 3"];
    final estado = ["Pendiente", "En proceso", "Completado"];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: Text("Regresar"), leadingWidth: 50),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  Text(
                    "Incidente",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  inputReutilizables(
                    controller: eventualidadController,
                    nameInput: "Eventualidad",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Completa el campo";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  ListaInputWigets(
                    label: "Selecciona un proyecto",
                    nameInput: "Proyecto",
                    items: proyecto,
                    value: state.proyecto,
                    onChanged: controller.setProyecto,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debes seleccionar un proyecto';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  FechaInputWidgets(
                    nameInput: 'Fecha',
                    fecha: state.fecha,
                    label: 'Selecciona la fecha',
                    onchanged: controller.setFecha,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  inputReutilizables(
                    controller: descripcionController,
                    nameInput: 'Descripcion',
                    maxLenght: 300,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  inputReutilizables(
                    controller: diasIncapacidadController,
                    nameInput: 'Dias de capacidad',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  inputReutilizables(
                    controller: avancesController,
                    nameInput: 'Avances',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  ListaInputWigets(
                    label: 'Seleccionar un estado',
                    nameInput: 'Estado',
                    items: estado,
                    value: state.estado,
                    onChanged: controller.setEstado,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () {
                      controller.sendForm(
                        context: context,
                        ref: ref,
                        onSuccess: () {},
                        controllersClear: [
                          eventualidadController,
                          descripcionController,
                          diasIncapacidadController,
                          avancesController,
                        ],
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 90,
                      ),
                      backgroundColor: CupertinoColors.activeBlue,
                    ),
                    child: Text(
                      "Enviar reporte",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
