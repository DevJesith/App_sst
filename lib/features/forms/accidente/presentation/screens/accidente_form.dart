// features/forms/accidente/presentation/screens/accidente_form_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/widgets/fecha_input_widgets.dart';
import '../../../../../shared/widgets/inputs_widgets.dart';
import '../../../../../shared/widgets/lista_input_wigets.dart';
import '../../domain/entities/accidente.dart';
import '../providers/accidente_providers.dart';

/// Pantalla para llenar el formulario de reporte de accidente.
/// Utiliza Clean Architecture + MVVM + Riverpod.
class AccidenteFormScreen extends HookConsumerWidget {
  final Accidente? accidente; // null = crear, con valor = editar

  const AccidenteFormScreen({Key? key, this.accidente}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Controladores de texto
    final eventualidadController = useTextEditingController(
      text: accidente?.eventualidad ?? '',
    );
    final contratistaController = useTextEditingController(
      text: accidente?.contratista ?? '',
    );
    final mesController = useTextEditingController(
      text: accidente?.mes ?? '',
    );
    final descripcionController = useTextEditingController(
      text: accidente?.descripcion ?? '',
    );
    final diasIncapacidadController = useTextEditingController(
      text: accidente?.diasIncapacidad.toString() ?? '',
    );
    final avancesController = useTextEditingController(
      text: accidente?.avances ?? '',
    );

    // Estado del formulario (valores de dropdowns y fecha)
    final formState = ref.watch(accidenteFormNotifierProvider);
    final formNotifier = ref.read(accidenteFormNotifierProvider.notifier);

    // Estado de envío
    final isSubmitting = ref.watch(accidentesSubmittingProvider);

    // Opciones de dropdown
    final proyectos = ["Proyecto 1", "Proyecto 2", "Proyecto 3"];
    final estados = ["Pendiente", "En proceso", "Completado"];

    // Inicializar valores si es edición
    useEffect(() {
      if (accidente != null) {
        formNotifier.setProyecto(accidente!.proyecto);
        formNotifier.setEstado(accidente!.estado);
        formNotifier.setFecha(accidente!.fechaRegistro);
      }
      return null;
    }, []);

    /// Función para enviar el formulario
    Future<void> submit() async {
      // Validar campos del form
      if (!formKey.currentState!.validate()) return;

      // Validar que los campos de estado estén completos
      if (formState.proyecto == null ||
          formState.estado == null ||
          formState.fecha == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa todos los campos')),
        );
        return;
      }

      // Crear entidad Accidente
      final nuevoAccidente = Accidente(
        id: accidente?.id,
        eventualidad: eventualidadController.text,
        proyecto: formState.proyecto!,
        contratista: contratistaController.text,
        mes: mesController.text,
        descripcion: descripcionController.text,
        diasIncapacidad: int.tryParse(diasIncapacidadController.text) ?? 0,
        avances: avancesController.text,
        estado: formState.estado!,
        fechaRegistro: formState.fecha!,
        usuarioId: 1, // TODO: Obtener del auth provider
      );

      // Llamar al notifier para crear/actualizar
      final notifier = ref.read(accidenteNotifierProvider.notifier);
      final success = accidente == null
          ? await notifier.crearAccidente(nuevoAccidente)
          : await notifier.actualizarAccidente(nuevoAccidente);

      if (context.mounted) {
        if (success) {
          // Limpiar formulario
          formNotifier.reset();
          eventualidadController.clear();
          contratistaController.clear();
          mesController.clear();
          descripcionController.clear();
          diasIncapacidadController.clear();
          avancesController.clear();

          // Mostrar diálogo de éxito
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Formulario enviado'),
              content: const Text('Completado con éxito'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Volver a pantalla anterior
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Mostrar error
          final error = ref.read(accidentesErrorProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Error desconocido')),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(accidente == null ? "Nuevo Accidente" : "Editar Accidente"),
        leadingWidth: 50,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                /// Título del formulario
                Text(
                  accidente == null ? "Nuevo Accidente" : "Editar Accidente",
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                /// Campo: Eventualidad
                inputReutilizables(
                  controller: eventualidadController,
                  nameInput: "Eventualidad",
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
                  nameInput: 'Proyecto',
                  label: 'Selecciona una opción',
                  items: proyectos,
                  value: formState.proyecto,
                  onChanged: formNotifier.setProyecto,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /// Campo: Contratista
                inputReutilizables(
                  controller: contratistaController,
                  nameInput: "Contratista",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /// Campo: Mes
                inputReutilizables(
                  controller: mesController,
                  nameInput: "Mes",
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
                  fecha: formState.fecha,
                  nameInput: 'Fecha',
                  label: 'Selecciona la fecha',
                  onchanged: formNotifier.setFecha,
                  validator: (value) {
                    if (value == null) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /// Campo: Descripción
                inputReutilizables(
                  controller: descripcionController,
                  nameInput: "Descripción",
                  maxLenght: 300,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Campo no definido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /// Campo: Días de incapacidad
                inputReutilizables(
                  controller: diasIncapacidadController,
                  nameInput: "Días de incapacidad",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Completa el campo";
                    }
                    if (int.tryParse(value) == null) {
                      return "Debe ser un número";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /// Campo: Avances
                inputReutilizables(
                  controller: avancesController,
                  nameInput: "Avances",
                  maxLenght: 300,
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
                  label: 'Selecciona una opción',
                  nameInput: 'Estado',
                  items: estados,
                  value: formState.estado,
                  onChanged: formNotifier.setEstado,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Este campo es obligatorio";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                /// Botón para enviar el formulario
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 90,
                    ),
                    backgroundColor: CupertinoColors.activeBlue,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
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