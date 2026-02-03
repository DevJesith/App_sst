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
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla para llenar el formulario de incidente.
/// Utiliza Riverpod para manejar estado y validación.
class IncidenteFormScreen extends HookConsumerWidget {
  final Incidente? incidente;

  const IncidenteFormScreen({Key? key, this.incidente}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // ----------------------------------------
    // 1. CONTROLADORES DE TEXTO
    // ----------------------------------------

    final eventualidadController = useTextEditingController(
      text: incidente?.eventualidad ?? '',
    );
    final descripcionController = useTextEditingController(
      text: incidente?.descripcion ?? '',
    );
    final diasIncapacidadController = useTextEditingController(
      text: incidente?.diasIncapacidad.toString() ?? '',
    );
    final avancesController = useTextEditingController(
      text: incidente?.avances ?? '',
    );

    // ----------------------------------------
    // 2. ESTADO Y PROVIDERS
    // ----------------------------------------

    // Estado del formulario
    final formState = ref.watch(incidenteFormNotifierProvider);
    final formNotifier = ref.read(incidenteFormNotifierProvider.notifier);

    // Estado de envio
    final isSubmitting = ref.watch(incidentesSubmittingProvider);

    final estado = ["Pendiente", "En proceso", "Completado"];

    // ----------------------------------------
    // 3. MAPEO DE NOMBRES
    // ----------------------------------------

    final nombresProyectos = formState.listaProyectos
        .map((e) => (e['Nombre'] ?? e['nombre']).toString())
        .toList();

    // Buscar el nombre del proyecto seleccionado basado en su ID
    String? nombresProyectoSeleccionado;
    if (formState.proyectoId != null && formState.listaProyectos.isNotEmpty) {
      try {
        final proyecto = formState.listaProyectos.firstWhere(
          (p) => p['id'] == formState.proyectoId,
        );
        nombresProyectoSeleccionado = proyecto['Nombre'] ?? proyecto['nombre'];
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
        double totalCampos = 7.0;
        int llenos = 0;

        // Verificamos campos de texto
        if (eventualidadController.text.isNotEmpty) llenos++;
        if (descripcionController.text.isNotEmpty) llenos++;
        if (diasIncapacidadController.text.isNotEmpty) llenos++;
        if (avancesController.text.isNotEmpty) llenos++;

        // Verificamos campos de seleccion
        if (formState.proyectoId != null) llenos++;
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

    /// Inicializacion
    /// - Cargar datos si es edicion o limpiar si es nuevo
    useEffect(() {
      Future.microtask(() {
        if (incidente != null) {
          // MODO EDICION: Cargar datos existentes al estado
          formNotifier.setProyectoId(incidente!.proyectoId);
          formNotifier.setEstado(incidente!.estado);
          formNotifier.setFecha(incidente!.fechaRegistro);
        } else {
          // MODO CREACION: Limpiar datos viejos
          formNotifier.reset();
        }
      });
      return null;
    }, []);

    // ----------------------------------------
    // 6. FUNCION DE ENVIO (SUBMIT)
    // ----------------------------------------

    Future<void> submit() async {
      // 1. Validar formulario visual
      if (!formKey.currentState!.validate()) return;

      // 2. Validar campos de estado
      if (formState.proyectoId == null ||
          formState.estado == null ||
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

      // Crear entidad Incidente
      final nuevoIncidente = Incidente(
        id: incidente?.id, // Mantiene el ID si es edición
        eventualidad: eventualidadController.text,
        proyectoId: formState.proyectoId!,
        descripcion: descripcionController.text,
        diasIncapacidad: int.tryParse(diasIncapacidadController.text) ?? 0,
        avances: avancesController.text,
        estado: formState.estado!,
        fechaRegistro: formState.fecha!,
        fechaCreacion: DateTime.now(),
        usuarioId: ref.read(usuarioAutenticadoProvider)?.id ?? 1,
      );

      // Llamar al notifier para guardar en BD
      final notifier = ref.read(incidenteNotifierProvider.notifier);
      final success = incidente == null
          ? await notifier.crearIncidente(nuevoIncidente)
          : await notifier.actualizarIncidente(nuevoIncidente);

      if (context.mounted) {
        if (success) {
          // Logica de sincronizacion automatica
          bool sincronizadoExitosamente = false;
          final hayInternet = await ConnectivityService.tieneInternet();

          if (hayInternet) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Conexión detectada. Sincronizando...'),
                duration: Duration(seconds: 1),
                backgroundColor: Colors.blue,
              ),
            );
            try {
              final resultado = await SyncService().sincronizarTodo();
              if (resultado['total']! > 0) sincronizadoExitosamente = true;
            } catch (e) {
              debugPrint("Error al sincronizar: $e");
            }
          }

          // Limpiar formulario tras exito
          formNotifier.reset();
          eventualidadController.clear();
          descripcionController.clear();
          diasIncapacidadController.clear();
          avancesController.clear();

          if (context.mounted) {
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
          final error = ref.read(incidentesErrorProvider);
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
        title: Text(incidente == null ? "Nuevo Incidente" : "Editar Incidente"),
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

          /// Formulario
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
                        const Text(
                          "Incidente",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                
                        // Campo: Eventualidad
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
                
                        // Dropdown: Proyecto
                        ListaInputWigets(
                          nameInput: 'Proyecto',
                          label: 'Selecciona un proyecto',
                          items: nombresProyectos,
                          value: nombresProyectoSeleccionado,
                          onChanged: (nombre) {
                            final proyecto = formState.listaProyectos.firstWhere(
                              (p) => (p['Nombre'] ?? p['nombre']) == nombre,
                            );
                            formNotifier.setProyectoId(proyecto['id'] as int);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                
                        // Campo: Fecha
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
                
                        // Campo: Descripcion
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
                
                        // Campo: Dias incapacidad
                        inputReutilizables(
                          controller: diasIncapacidadController,
                          nameInput: 'Dias de incapacidad',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                
                        // Campo: Avances
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
                
                        // Dropdown: Estado
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
                              ? const CircularProgressIndicator(color: Colors.white)
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
