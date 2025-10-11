import 'package:app_sst/core/widgets/inputs_widgets.dart';
import 'package:app_sst/core/widgets/lista_input_wigets.dart';
import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla para llenar el formulario de registro de capacitaciones.
/// Utiliza Riverpod para manejar estado y validación.
class CapacitacionForm extends HookConsumerWidget {
  const CapacitacionForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      capacitacionFormProvider.notifier,
    ); // Controlador del formulario

    final state = ref.watch(
      capacitacionFormProvider,
    ); // Estado actual del formulario

    // Controladores de texto para los campos

    final noCapacitacionesController = useTextEditingController();
    final noPersonasController = useTextEditingController();
    final responsableController = useTextEditingController();
    final temaController = useTextEditingController();

    // Opciones de dropdown
    final proyectos = ["Proyecto 1", "Proyecto 2", "Proyecto 3"];
    final contratista = ["Contratista 1", "Contratista 2", "Contratista 3"];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: Text('Regresar'), leadingWidth: 40),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                /// Título del formulario
                Text(
                  'Registro Capacitaciones',
                  style: TextStyle(
                    fontSize: 27,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                /// Campo: Número de capacitaciones
                inputReutilizables(
                  controller: noCapacitacionesController,
                  nameInput: 'No de capacitaciones',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Dropdown: Proyecto
                ListaInputWigets(
                  label: 'Selecciona un proyecto',
                  nameInput: 'Proyecto',
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

                /// Dropdown: Contratista
                ListaInputWigets(
                  label: 'Contratista',
                  nameInput: 'Contratista',
                  items: contratista,
                  value: state.contratista,
                  onChanged: controller.setContratista,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Campo: Número de personas
                inputReutilizables(
                  controller: noPersonasController,
                  nameInput: 'No de Personas',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Campo: Responsable
                inputReutilizables(
                  controller: responsableController,
                  nameInput: 'Responsable',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Campo: Tema
                inputReutilizables(
                  controller: temaController,
                  nameInput: 'Tema',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
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
                        noCapacitacionesController,
                        noPersonasController,
                        noPersonasController,
                        temaController,
                        responsableController,
                      ],
                    );
                  },

                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 100,
                    ),
                    backgroundColor: CupertinoColors.activeBlue,
                  ),
                  child: Text(
                    'Enviar reporte',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
