import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/presentation/providers/incidente_providers.dart';
import 'package:app_sst/shared/widgets/fecha_input_widgets.dart';
import 'package:app_sst/shared/widgets/inputs_widgets.dart';
import 'package:app_sst/shared/widgets/lista_input_wigets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla para llenar el formulario de reporte de incidente.
/// Utiliza Riverpod para manejar estado y validación.
class IncidenteFormScreen extends HookConsumerWidget {
  final Incidente? incidente;

  const IncidenteFormScreen({Key? key, this.incidente}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Controladores de texto
    final eventualidadController = useTextEditingController(
      text: incidente?.eventualidad ?? '',
    );

    final mesController = useTextEditingController(text: incidente?.mes ?? '');

    final descripcionController = useTextEditingController(
      text: incidente?.descripcion ?? '',
    );

    final diasIncapacidadController = useTextEditingController(
      text: incidente?.diasIncapacidad.toString() ?? '',
    );

    final avancesController = useTextEditingController(
      text: incidente?.avances ?? '',
    );

    //Estado del formulario (valores de dropdowns y fecha)
    final formState = ref.watch(incidenteFormNotifierProvider);
    final formNotifier = ref.read(incidenteFormNotifierProvider.notifier);

    //Estado de envio
    final isSubmitting = ref.watch(incidentesSubmittingProvider);

    // Opciones de dropdown
    final proyecto = ["Proyecto 1", "Proyecto 2", "Proyecto 3"];
    final estado = ["Pendiente", "En proceso", "Completado"];

    //Inincializar valores si es edicion
    useEffect(() {
      if (incidente != null) {
        formNotifier.setProyecto(incidente!.proyecto);
        formNotifier.setEstado(incidente!.estado);
        formNotifier.setFecha(incidente!.fechaRegistro);
      }
      return null;
    }, []);

    // Funcion para enviar el formulario
    Future<void> submit() async {
      //Validar campos del form
      if (!formKey.currentState!.validate()) return;

      //Validar que los campos de estado esten completos
      if (formState.proyecto == null ||
          formState.estado == null ||
          formState.fecha == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor compelta todos los campos')),
        );
        return;
      }

      //Crear entidad Incidente
      final nuevoIncidente = Incidente(
        id: incidente?.id,
        eventualidad: eventualidadController.text,
        proyecto: formState.proyecto!,
        mes: mesController.text,
        descripcion: descripcionController.text,
        diasIncapacidad: int.tryParse(diasIncapacidadController.text) ?? 0,
        avances: avancesController.text,
        estado: formState.estado!,
        fechaRegistro: formState.fecha!,
        usuarioId: ref.read(usuarioAutenticadoProvider)?.id ?? 1,
      );

      //Llamar al notifier para crear/actualizar
      final notifier = ref.read(incidenteNotifierProvider.notifier);
      final success = incidente == null
          ? await notifier.crearIncidente(nuevoIncidente)
          : await notifier.actualizarIncidente(nuevoIncidente);

      if (context.mounted) {
        if (success) {
          //Limpiar formulario
          formNotifier.reset();
          eventualidadController.clear();
          mesController.clear();
          descripcionController.clear();
          diasIncapacidadController.clear();
          avancesController.clear();

          //Mostrar dialogo de exito
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Formulario enviado'),
              content: const Text('Completado con exito'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          //Mostrar error
          final error = ref.read(incidentesErrorProvider);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error ?? 'Error desconocido')));
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(incidente == null ? "Nuevo Incidente" : "Editar Incidente"),
        leadingWidth: 50,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  /// Título del formulario
                  Text(
                    "Incidente",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  /// Campo: Eventualidad
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

                  /// Dropdown: Proyecto
                  ListaInputWigets(
                    label: "Selecciona un proyecto",
                    nameInput: "Proyecto",
                    items: proyecto,
                    value: formState.proyecto,
                    onChanged: formNotifier.setProyecto,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debes seleccionar un proyecto';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  /// Selector de fecha
                  FechaInputWidgets(
                    nameInput: 'Fecha',
                    fecha: formState.fecha,
                    label: 'Selecciona la fecha',
                    onchanged: formNotifier.setFecha,
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
                    nameInput: 'Dias de capacidad',
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
                    label: 'Seleccionar un estado',
                    nameInput: 'Estado',
                    items: estado,
                    value: formState.estado,
                    onChanged: formNotifier.setEstado,
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
      ),
    );
  }
}
