import 'package:app_sst/core/widgets/fecha_input_widgets.dart';
import 'package:app_sst/core/widgets/inputs_widgets.dart';
import 'package:app_sst/core/widgets/lista_input_wigets.dart';
import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla para llenar el formulario de reporte de accidente.
/// Utiliza Riverpod para manejar estado y validación.
class AccidenteForm extends HookConsumerWidget {
  const AccidenteForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      accidenteFormProvider.notifier,
    ); // Controlador del formulario
    final state = ref.watch(
      accidenteFormProvider,
    ); // Estado actual del formulario

    // Controladores de texto para los campos
    final evetualidadController = useTextEditingController();
    final descripcionController = useTextEditingController();
    final diasIncapacidadController = useTextEditingController();
    final avancesController = useTextEditingController();

    // Opciones de dropdown
    final proyectos = ["Proyecto 1", "Proyecto 2", "Proyecto 3"];
    final estados = ["Pendiente", "En proceso", "Completado"];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: Text("Regresar"), leadingWidth: 50),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                /// Título del formulario
                Text(
                  "Accidente",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                /// Campo: Eventualidad
                inputReutilizables(
                  controller: evetualidadController,
                  nameInput: "Eventualidad",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligaotrio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Dropdown: Proyecto
                ListaInputWigets(
                  nameInput: 'Proyecto',
                  label: 'Selecciona una opcion',
                  items: proyectos,
                  value: state.proyecto,
                  onChanged: controller.setProyecto,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Selector de fecha
                FechaInputWidgets(
                  fecha: state.fecha,
                  nameInput: 'Fecha',
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

                /// Campo: Descripción
                inputReutilizables(
                  controller: descripcionController,
                  nameInput: "Descripcion",
                  maxLenght: 300,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Campo no definido";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 5),

                /// Campo: Días de incapacidad
                inputReutilizables(
                  controller: diasIncapacidadController,
                  nameInput: "Dias de incapacidad",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Completa el campo";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Campo: Avances
                inputReutilizables(
                  controller: avancesController,
                  nameInput: "Avances",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Completa el campo";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Dropdown: Estado
                ListaInputWigets(
                  label: 'Selecciona una opcion',
                  nameInput: 'Estado',
                  items: estados,
                  value: state.estado,
                  onChanged: controller.setEstado,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Este campo es obligaotrio";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Botón para enviar el formulario
                ElevatedButton(
                  onPressed: () {
                    controller.sendForm(
                      context: context,
                      ref: ref,
                      onSuccess: () {},
                      controllersClear: [
                        evetualidadController,
                        descripcionController,
                        descripcionController,
                        diasIncapacidadController,
                        avancesController,
                      ],
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 90),
                    backgroundColor: CupertinoColors.activeBlue,
                  ),
                  child: Text(
                    "Enviar reporte",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
