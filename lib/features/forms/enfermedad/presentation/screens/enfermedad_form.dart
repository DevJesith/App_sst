import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/presentation/providers/enfermedad_providers.dart';
import 'package:app_sst/shared/widgets/fecha_input_widgets.dart';
import 'package:app_sst/shared/widgets/inputs_widgets.dart';
import 'package:app_sst/shared/widgets/lista_input_wigets.dart';
import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla para llenar el formulario de enfermedad laboral.
/// Utiliza Riverpod para manejar estado y validación.
class EnfermedadFormScreen extends HookConsumerWidget {
  final Enfermedad? enfermedad;

  const EnfermedadFormScreen({Key? key, this.enfermedad}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    //Controladores de texto
    final eventualidadController = useTextEditingController(
      text: enfermedad?.eventualidad ?? '',
    );

    final contratistaController = useTextEditingController(
      text: enfermedad?.contratista ?? '',
    );

    final mesController = useTextEditingController(text: enfermedad?.mes ?? '');

    final descripcionController = useTextEditingController(
      text: enfermedad?.descripcion ?? '',
    );

    final diasIncapacidadController = useTextEditingController(
      text: enfermedad?.diasIncapacidad.toString() ?? '',
    );

    final avancesController = useTextEditingController(
      text: enfermedad?.avances ?? '',
    );

    //Estado del formulario (valores de dropdowns y fecha)
    final formState = ref.watch(enfermedadFormNotifierProvider);

    final formNotifier = ref.read(enfermedadFormNotifierProvider.notifier);

    //Estado de envio
    final isSubmitting = ref.watch(enfermedadSubmittingProvider);

    // Opciones de dropdown
    final proyectos = ["Proyecto 1", "Proyecto 2", "Proyecto 3"];
    final contratista = ["Contratista 1", "Contratista 2", "Contratista 3"];
    final estado = ["Pendiente", "En proceso", "Completado"];

    //Inicializar valores si es edicion
    useEffect(() {
      if (enfermedad != null) {
        formNotifier.setProyecto(enfermedad!.proyecto);
        formNotifier.setEstado(enfermedad!.estado);
        formNotifier.setFecha(enfermedad!.fechaRegistro);
      }
      return null;
    }, []);

    //Funcion para enviar el formulario
    Future<void> submit() async {
      //Validar campos del form
      if (!formKey.currentState!.validate()) return;

      //Validar que los campos de estado esten completos
      if (formState.proyecto == null ||
          formState.estado == null ||
          formState.contratista == null ||
          formState.fecha == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa todos los campos')),
        );
        return;
      }

      //Crear entidad Enfermedad
      final nuevoEnfermedad = Enfermedad(
        id: enfermedad?.id,
        eventualidad: eventualidadController.text,
        proyecto: formState.proyecto!,
        contratista: formState.contratista!,
        mes: mesController.text,
        descripcion: descripcionController.text,
        diasIncapacidad: int.tryParse(diasIncapacidadController.text) ?? 0,
        avances: avancesController.text,
        estado: formState.estado!,
        fechaRegistro: formState.fecha!,
        usuarioId: 1,
      );

      //Llamar al notifier para crear/actualizar
      final notifier = ref.read(enfermedadNotifierProvider.notifier);
      final success = enfermedad == null
          ? await notifier.crearEnfermedad(nuevoEnfermedad)
          : await notifier.actualizarEnfermedad(nuevoEnfermedad);

      if (context.mounted) {
        if (success) {
          //Limpiar formulario
          formNotifier.reset();
          eventualidadController.clear();
          contratistaController.clear();
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
          final error = ref.read(enfermedadErrorProvider);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error ?? 'Error desconocido')));
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          enfermedad == null ? "Nueva Enfermedad" : "Editar Enfermedad",
        ),
        leadingWidth: 50,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: formKey,
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

                // /// Dropdown: Contratista
                ListaInputWigets(
                  label: 'Selecciona un contratista',
                  nameInput: 'Contratista',
                  items: contratista,
                  value: formState.contratista,
                  onChanged: formNotifier.setContratista,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),

                // const SizedBox(height: 20),

                /// Selector de fecha
                FechaInputWidgets(
                  fecha: formState.fecha,
                  nameInput: 'Fecha',
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
    );
  }
}
