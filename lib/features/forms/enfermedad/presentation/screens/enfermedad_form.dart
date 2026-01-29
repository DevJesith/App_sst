import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/forms/enfermedad/domain/entities/enfermedad.dart';
import 'package:app_sst/features/forms/enfermedad/presentation/providers/enfermedad_providers.dart';
import 'package:app_sst/services/connectivity_service.dart';
import 'package:app_sst/services/sync_service.dart';
import 'package:app_sst/shared/widgets/fecha_input_widgets.dart';
import 'package:app_sst/shared/widgets/inputs_widgets.dart';
import 'package:app_sst/shared/widgets/lista_input_wigets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final estado = ["Pendiente", "En proceso", "Completado"];

    final nombresProyectos = formState.listaProyectos
        .map((e) => (e['Nombre'] ?? e['nombre']).toString())
        .toList();

    final nombresContratistas = formState.listaContratista
        .map((e) => (e['Nombre'] ?? e['nombre']).toString())
        .toList();

    final nombresTrabajadores = formState.listaTrabajadores
        .map(
          (e) => (e['Nombres'] ?? e['nombres'] ?? e['Nombre'] ?? e['nombre'])
              .toString(),
        )
        .toList();

    String? nombresProyectoSeleccionado;
    if (formState.proyectoId != null && formState.listaProyectos.isNotEmpty) {
      try {
        final proyecto = formState.listaProyectos.firstWhere(
          (p) => p['id'] == formState.proyectoId,
        );
        nombresProyectoSeleccionado = proyecto['Nombre'] ?? proyecto['nombre'];
      } catch (_) {}
    }

    String? nombresContratistaSeleccionado;
    if (formState.contratistaId != null &&
        formState.listaContratista.isNotEmpty) {
      try {
        final contratistas = formState.listaContratista.firstWhere(
          (c) => c['id'] == formState.contratistaId,
        );
        nombresContratistaSeleccionado =
            contratistas['Nombre'] ?? contratistas['nombre'];
      } catch (_) {}
    }

    String? nombresTrabajadoresSeleccionado;
    if (formState.trabajadorId != null &&
        formState.listaTrabajadores.isNotEmpty) {
      try {
        final trabajadores = formState.listaTrabajadores.firstWhere(
          (t) => t['id'] == formState.trabajadorId,
        );
        nombresTrabajadoresSeleccionado =
            trabajadores['Nombres'] ??
            trabajadores['nombres'] ??
            trabajadores['Nombre'];
      } catch (_) {}
    }

    //Inicializar valores si es edicion
    useEffect(() {
      Future.microtask(() async {
        if (enfermedad != null) {
          // PARA EDITAR

          formNotifier.setEstado(enfermedad!.estado);
          formNotifier.setFecha(enfermedad!.fechaRegistro);

          formNotifier.setProyectoId(enfermedad!.proyectoId);

          await Future.delayed(const Duration(milliseconds: 300));

          formNotifier.setContratistaId(enfermedad!.contratistaId);

          await Future.delayed(const Duration(milliseconds: 300));

          formNotifier.setTrabajadorId(enfermedad!.trabajadorId);
        } else {
          formNotifier.reset();
        }
      });
      return null;
    }, []);

    //Funcion para enviar el formulario
    Future<void> submit() async {
      //Validar campos del form
      if (!formKey.currentState!.validate()) return;

      //Validar que los campos de estado esten completos
      if (formState.proyectoId == null ||
          formState.estado == null ||
          formState.trabajadorId == null ||
          formState.contratistaId == null ||
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
        proyectoId: formState.proyectoId!,
        contratistaId: formState.contratistaId!,
        trabajadorId: formState.trabajadorId!,
        descripcion: descripcionController.text,
        diasIncapacidad: int.tryParse(diasIncapacidadController.text) ?? 0,
        avances: avancesController.text,
        estado: formState.estado!,
        fechaRegistro: formState.fecha!,
        usuarioId: ref.read(usuarioAutenticadoProvider)?.id ?? 1,
      );

      //Llamar al notifier para crear/actualizar
      final notifier = ref.read(enfermedadNotifierProvider.notifier);
      final success = enfermedad == null
          ? await notifier.crearEnfermedad(nuevoEnfermedad)
          : await notifier.actualizarEnfermedad(nuevoEnfermedad);

      if (context.mounted) {
        if (success) {
          bool sincronizadoExitosamente = false;

          final hayInternet = await ConnectivityService.tieneInternet();
          if (hayInternet) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Conexión detectada. Sincronizando...'),
                backgroundColor: Colors.blue,
              ),
            );

            try {
              final resultado = await SyncService().sincronizarTodo();

              if (resultado['total']! > 0) {
                sincronizadoExitosamente = true;
              }
            } catch (e) {
              print("Error al sincronizar: $e");
            }
          }

          //Limpiar formulario
          formNotifier.reset();
          eventualidadController.clear();
          descripcionController.clear();
          diasIncapacidadController.clear();
          avancesController.clear();

          if (context.mounted) {
            //Mostrar dialogo de exito
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Éxito'),
                content: Text(
                  sincronizadoExitosamente
                      ? 'Reporte creado y sincronizado con la nube.'
                      : 'Reporte guardado localmente. Se subirá cuando tengas internet.',
                ),
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
          }
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

                // Proyecto
                ListaInputWigets(
                  nameInput: 'Proyecto',
                  label: 'Selecciona un proyecto',
                  items: nombresProyectos,
                  value:
                      nombresProyectoSeleccionado, // Le pasamos el nombre, no el ID
                  onChanged: (nombre) {
                    // BUSCAR EL ID BASADO EN EL NOMBRE SELECCIONADO
                    final proyecto = formState.listaProyectos.firstWhere(
                      (p) => (p['Nombre'] ?? p['nombre']) == nombre,
                    );
                    // Mandar el ID al notifier
                    formNotifier.setProyectoId(proyecto['id'] as int);
                  },
                  validator: (value) => value == null ? 'Requerido' : null,
                ),

                const SizedBox(height: 20),

                // Contratista
                ListaInputWigets(
                  nameInput: 'Contratista',
                  label: nombresContratistas.isEmpty
                      ? 'Selecciona un proyecto primero'
                      : 'Selecciona un contratista',
                  items: nombresContratistas,
                  value: nombresContratistaSeleccionado, // Le pasamos el nombre
                  onChanged: (nombre) {
                    // BUSCAR EL ID BASADO EN EL NOMBRE
                    final contratista = formState.listaContratista.firstWhere(
                      (c) => (c['Nombre'] ?? c['nombre']) == nombre,
                    );
                    // Mandar el ID al notifier
                    formNotifier.setContratistaId(contratista['id'] as int);
                  },
                  validator: (value) => value == null ? 'Requerido' : null,
                ),

                const SizedBox(height: 20),

                // Trabajador
                ListaInputWigets(
                  nameInput: 'Trabajador',
                  label: nombresTrabajadores.isEmpty
                      ? 'Selecciona un proyecto primero'
                      : 'Selecciona un contratista',
                  items: nombresTrabajadores,
                  value:
                      nombresTrabajadoresSeleccionado, // Le pasamos el nombre
                  onChanged: (nombre) {
                    // BUSCAR EL ID BASADO EN EL NOMBRE
                    final trabajador = formState.listaTrabajadores.firstWhere(
                      (t) =>
                          (t['Nombres'] ?? t['nombres'] ?? t['Nombre']) ==
                          nombre,
                    );
                    // Mandar el ID al notifier
                    formNotifier.setTrabajadorId(trabajador['id'] as int);
                  },
                  validator: (value) => value == null ? 'Requerido' : null,
                ),
                const SizedBox(height: 20),

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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (int.tryParse(value) == null) {
                      return "Debe ser un número";
                    }
                    final numero = int.tryParse(value);
                    if ( numero == null || numero <= 0) {
                      return 'Debe ser un numero mayor a 0';
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
                      vertical: 16,
                      horizontal: 100,
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
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
