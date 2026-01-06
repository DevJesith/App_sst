import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/forms/incidente/domain/entities/incidente.dart';
import 'package:app_sst/features/forms/incidente/presentation/providers/incidente_providers.dart';
import 'package:app_sst/services/connectivity_service.dart';
import 'package:app_sst/services/sync_service.dart';
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
    final estado = ["Pendiente", "En proceso", "Completado"];

    int? valorProyectoSeguro = formState.proyectoId;

    final nombresProyectos = formState.listaProyectos
        .map((e) => (e['Nombre'] ?? e['nombre']).toString())
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

    if (formState.listaProyectos.isNotEmpty && valorProyectoSeguro != null) {
      final existe = formState.listaProyectos.any(
        (p) => p['id'] == valorProyectoSeguro,
      );
      if (!existe) {
        valorProyectoSeguro = null;
        // Opcional: Actualizar el estado para que sepa que es null
        // Future.microtask(() => formNotifier.setProyectoId(null));
      }
    }

    //Inincializar valores si es edicion
    useEffect(() {
      if (incidente != null) {
        Future.microtask(() {
          formNotifier.setProyectoId(incidente!.proyectoId);
          formNotifier.setEstado(incidente!.estado);
          formNotifier.setFecha(incidente!.fechaRegistro);
        });
      }
      return null;
    }, []);

    // Funcion para enviar el formulario
    Future<void> submit() async {
      //Validar campos del form
      if (!formKey.currentState!.validate()) return;

      //Validar que los campos de estado esten completos
      if (formState.proyectoId == null ||
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
        proyectoId: formState.proyectoId!,
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
          bool sincronizadoExitosamente = false;

          final hayInternet = await ConnectivityService.tieneInternet();
          if (hayInternet) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Conexión detectada. Sincronizando...'),
                duration: Duration(seconds: 2),
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
          mesController.clear();
          descripcionController.clear();
          diasIncapacidadController.clear();
          avancesController.clear();

          //Mostrar dialogo de exito
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Éxito'),
                content: Text(
                  sincronizadoExitosamente
                      ? 'Reporte creado y sincronizando con la nube.'
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

                  // PROYECTO (
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
      ),
    );
  }
}
