// features/forms/capacitacion/presentation/screens/capacitacion_form_screen.dart

import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/widgets/inputs_widgets.dart';
import '../../../../../shared/widgets/lista_input_wigets.dart';
import '../../domain/entities/capacitacion.dart';
import '../providers/capacitacion_providers.dart';

class CapacitacionFormScreen extends HookConsumerWidget {
  final Capacitacion? capacitacion;

  const CapacitacionFormScreen({Key? key, this.capacitacion}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Controllers
    final descripcionController = useTextEditingController(
      text: capacitacion?.descripcion ?? '',
    );
    final numeroCapacitaController = useTextEditingController(
      text: capacitacion?.numeroCapacita.toString() ?? '',
    );
    final numeroPersonasController = useTextEditingController(
      text: capacitacion?.numeroPersonas.toString() ?? '',
    );
    final responsableController = useTextEditingController(
      text: capacitacion?.responsable ?? '',
    );

    // Estado del formulario
    final formState = ref.watch(capacitacionFormNotifierProvider);
    final formNotifier = ref.read(capacitacionFormNotifierProvider.notifier);

    final isSubmitting = ref.watch(capacitacionesSubmittingProvider);

    // Opciones de dropdowns (con IDs)
    // TODO: Estos deberían venir de la base de datos
    final proyectos = [
      {'id': 1, 'nombre': 'Proyecto 1'},
      {'id': 2, 'nombre': 'Proyecto 2'},
      {'id': 3, 'nombre': 'Proyecto 3'},
    ];

    final contratistas = [
      {'id': 1, 'nombre': 'Contratista A'},
      {'id': 2, 'nombre': 'Contratista B'},
      {'id': 3, 'nombre': 'Contratista C'},
    ];

    // Inicializar valores si es edición
    useEffect(() {
      if (capacitacion != null) {
        formNotifier.setIdProyecto(capacitacion!.idProyecto);
        formNotifier.setIdContratista(capacitacion!.idContratista);
      }
      return null;
    }, []);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;

      if (formState.idProyecto == null || formState.idContratista == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa todos los campos')),
        );
        return;
      }

      final nuevaCapacitacion = Capacitacion(
        id: capacitacion?.id,
        idProyecto: formState.idProyecto!,
        idContratista: formState.idContratista!,
        descripcion: descripcionController.text,
        numeroCapacita: int.tryParse(numeroCapacitaController.text) ?? 0,
        numeroPersonas: int.tryParse(numeroPersonasController.text) ?? 0,
        responsable: responsableController.text,
        fechaRegistro: DateTime.now(),
        usuarioId: ref.read(usuarioAutenticadoProvider)?.id ?? 1, // TODO: Obtener del auth provider
      );

      final notifier = ref.read(capacitacionNotifierProvider.notifier);
      final success = capacitacion == null
          ? await notifier.createCapacitacion(nuevaCapacitacion)
          : await notifier.updateCapacitacion(nuevaCapacitacion);

      if (context.mounted) {
        if (success) {
          formNotifier.reset();
          descripcionController.clear();
          numeroCapacitaController.clear();
          numeroPersonasController.clear();
          responsableController.clear();

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Formulario enviado'),
              content: const Text('Completado con éxito'),
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
          final error = ref.read(capacitacionesErrorProvider);
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
          capacitacion == null ? "Nueva Capacitación" : "Editar Capacitación",
        ),
        leadingWidth: 50,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Text(
                  'Capacitación',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Dropdown: Proyecto
                DropdownButtonFormField<int>(
                  value: formState.idProyecto,
                  decoration: const InputDecoration(
                    labelText: 'Proyecto',
                    border: OutlineInputBorder(),
                  ),
                  items: proyectos.map((proyecto) {
                    return DropdownMenuItem<int>(
                      value: proyecto['id'] as int,
                      child: Text(proyecto['nombre'] as String),
                    );
                  }).toList(),
                  onChanged: formNotifier.setIdProyecto,
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona un proyecto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Dropdown: Contratista
                DropdownButtonFormField<int>(
                  value: formState.idContratista,
                  decoration: const InputDecoration(
                    labelText: 'Contratista',
                    border: OutlineInputBorder(),
                  ),
                  items: contratistas.map((contratista) {
                    return DropdownMenuItem<int>(
                      value: contratista['id'] as int,
                      child: Text(contratista['nombre'] as String),
                    );
                  }).toList(),
                  onChanged: formNotifier.setIdContratista,
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona un contratista';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Descripción
                inputReutilizables(
                  controller: descripcionController,
                  nameInput: 'Descripción',
                  maxLenght: 30,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Número de Capacitación
                inputReutilizables(
                  controller: numeroCapacitaController,
                  nameInput: 'Número de Capacitación',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Debe ser un número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Número de Personas
                inputReutilizables(
                  controller: numeroPersonasController,
                  nameInput: 'Número de Personas',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Debe ser un número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Responsable
                inputReutilizables(
                  controller: responsableController,
                  nameInput: 'Responsable',
                  maxLenght: 30,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botón para enviar
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
