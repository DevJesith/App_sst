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

    // ----------------------------------------
    // 1. CONTROLADORES DE TEXTO
    // ----------------------------------------

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

    // ----------------------------------------
    // 2. ESTADO Y PROVIDERS
    // ----------------------------------------

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

    // ----------------------------------------
    // 3. MAPEO DE NOMBRES
    // ----------------------------------------

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

    // ----------------------------------------
    // 4. LOGICA DE BARRA DE PROGRESO
    //-----------------------------------------

    // Estado local para el porcentaje (0.0 a 1.0)
    final progreso = useState<double>(0.0);

    /// Calcula que porcentaje del formulario ha sido diligenciado.
    /// Se envuelve en [Future.microtask] para evitar errores de renderizado.
    void calcularProgreso() {
      Future.microtask(() {
        // Total de campos
        double totalCampos = 9.0;
        int llenos = 0;

        // Verificamos campos de texto
        if (eventualidadController.text.isNotEmpty) llenos++;
        if (descripcionController.text.isNotEmpty) llenos++;
        if (diasIncapacidadController.text.isNotEmpty) llenos++;
        if (avancesController.text.isNotEmpty) llenos++;

        // Verificamos campos de seleccion
        if (formState.proyectoId != null) llenos++;
        if (formState.contratistaId != null) llenos++;
        if (formState.trabajadorId != null) llenos++;
        if (formState.fecha != null) llenos++;
        if (formState.estado != null) llenos++;

        // Calculamos el procentaje y aseguramos que este entre 0 y 1
        progreso.value = (llenos / totalCampos).clamp(0.0, 1.0);
      });
    }

    // EFECTO 1: Escuchar cambios en los campos de texto
    useEffect(() {
      // Creamos una funcion oyente
      void listener() => calcularProgreso();

      // Le ponemos como tal "oido" a cada controlador
      eventualidadController.addListener(listener);
      descripcionController.addListener(listener);
      diasIncapacidadController.addListener(listener);
      avancesController.addListener(listener);

      // Limpieza para quitar los listeners al salir para liberar memoria
      return () {
        eventualidadController.removeListener(listener);
        descripcionController.removeListener(listener);
        diasIncapacidadController.removeListener(listener);
        avancesController.removeListener(listener);
      };
    }, [formState]);

    // EFECTO 2: Escucha Dropdowns y Fecha (Riverpod)
    // Este efecto se ejecuta cada vez que 'formState' cambia
    useEffect(() {
      calcularProgreso();
      return null;
    }, [formState]);

    // ----------------------------------------
    // 5. LOGICA DE CARGA DE DATOS
    // ---------------------------------------

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

    // ----------------------------------------
    // 6. FUNCION DE ENVIO (SUBMIT)
    // ----------------------------------------

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

      // 3. Validar que el progreso este al 100%
      if (progreso.value < 1.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Falta completar el formulario (${(progreso.value * 100).toInt()}%)',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return; // Ayuda a detener el envio
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
        fechaCreacion: DateTime.now(),
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

    /// Determina el color de la barra y el texto segun el porcentaje
    Color getColorProgreso(double valor) {
      if (valor < 0.5) return Colors.red; // Menos de 50
      if (valor < 1.0) return Colors.orange; // Menos de 100
      return Colors.green; // 100
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          enfermedad == null ? "Nueva Enfermedad" : "Editar Enfermedad",
        ),
        leadingWidth: 50,
      ),
      body: Column(
        children: [
          /// Barra de Progreso
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila de textos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Completado",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${(progreso.value * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: getColorProgreso(progreso.value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Barra visual
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progreso.value,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade100,
                    color: getColorProgreso(progreso.value),
                  ),
                ),
              ],
            ),
          ),
          // Linea divisoria para separar del formulario
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
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
                          validator: (value) =>
                              value == null ? 'Requerido' : null,
                        ),
              
                        const SizedBox(height: 20),
              
                        // Contratista
                        ListaInputWigets(
                          nameInput: 'Contratista',
                          label: nombresContratistas.isEmpty
                              ? 'Selecciona un proyecto primero'
                              : 'Selecciona un contratista',
                          items: nombresContratistas,
                          value:
                              nombresContratistaSeleccionado, // Le pasamos el nombre
                          onChanged: (nombre) {
                            // BUSCAR EL ID BASADO EN EL NOMBRE
                            final contratista = formState.listaContratista
                                .firstWhere(
                                  (c) => (c['Nombre'] ?? c['nombre']) == nombre,
                                );
                            // Mandar el ID al notifier
                            formNotifier.setContratistaId(
                              contratista['id'] as int,
                            );
                          },
                          validator: (value) =>
                              value == null ? 'Requerido' : null,
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
                            final trabajador = formState.listaTrabajadores
                                .firstWhere(
                                  (t) =>
                                      (t['Nombres'] ??
                                          t['nombres'] ??
                                          t['Nombre']) ==
                                      nombre,
                                );
                            // Mandar el ID al notifier
                            formNotifier.setTrabajadorId(trabajador['id'] as int);
                          },
                          validator: (value) =>
                              value == null ? 'Requerido' : null,
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
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es obligatorio';
                            }
                            if (int.tryParse(value) == null) {
                              return "Debe ser un número";
                            }
                            final numero = int.tryParse(value);
                            if (numero == null || numero <= 0) {
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
            ),
          ),
        ],
      ),
    );
  }
}
