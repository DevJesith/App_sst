import 'package:app_sst/core/widgets/fecha_input_widgets.dart';
import 'package:app_sst/core/widgets/inputs_widgets.dart';
import 'package:app_sst/core/widgets/lista_input_wigets.dart';
import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla para llenar el formulario de enfermedad laboral.
/// Utiliza Riverpod para manejar estado y validación.
class EnfermedadForm extends HookConsumerWidget {
  const EnfermedadForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(enfermedadFormProvider.notifier);
    final state = ref.watch(enfermedadFormProvider);

    // Controladores de texto para los campos
    final eventualidadController = useTextEditingController();
    final descripcionController = useTextEditingController();
    final diasIncapacidadController = useTextEditingController();
    final avancesController = useTextEditingController();

    // Opciones de dropdown
    final proyectos = ["Proyecto 1", "Proyecto 2", "Proyecto 3"];
    final contratista = ["Contratista 1", "Contratista 2", "Contratista 3"];
    final estado = ["Pendiente", "En proceso", "Completado"];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: Text('Regresar'), leadingWidth: 50),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                /// Título del formulario
                Text(
                  'Enfermedad Laboral',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                /// Campo: Eventualidad
                inputReutilizables(
                  controller: eventualidadController,
                  nameInput: 'Eventualidad',
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
                  label: 'Seleccionar proyecto',
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
                  label: 'Selecciona un contratista',
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

                /// Campo: Días de incapacidad
                inputReutilizables(
                  controller: diasIncapacidadController,
                  nameInput: 'Dias de incapacidad',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Campo: Avances
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

                /// Dropdown: Estado
                ListaInputWigets(
                  label: 'Selecciona un estado',
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

                /// Botón para enviar el formulario
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
