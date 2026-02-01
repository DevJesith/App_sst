import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/services/connectivity_service.dart';
import 'package:app_sst/services/sync_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/widgets/fecha_input_widgets.dart';
import '../../../../../shared/widgets/inputs_widgets.dart';
import '../../../../../shared/widgets/lista_input_wigets.dart';
import '../../domain/entities/accidente.dart';
import '../providers/accidente_providers.dart';

/// Pantalla para llenar el formulario de reporte de accidente.
///
/// Utiliza Clean Architecture + MVVM + Riverpod.
/// Maneja la logica de cascada: Seleccion de Proyecto -> Carga de Contratistas.
class AccidenteFormScreen extends HookConsumerWidget {
  /// Si es null, se crea un nuevo registro.
  /// Si tiene valor, se edita el registro existente.
  final Accidente? accidente;

  const AccidenteFormScreen({Key? key, this.accidente}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Clave para validar el formulario
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // ----------------------------------------
    // 1. CONTROLADORES DE TEXTO
    // ----------------------------------------

    final eventualidadController = useTextEditingController(
      text: accidente?.eventualidad ?? '',
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

    // ----------------------------------------
    // 2. ESTADO Y PROVIDERS
    // ----------------------------------------

    final formState = ref.watch(accidenteFormNotifierProvider);
    final formNotifier = ref.read(accidenteFormNotifierProvider.notifier);
    final isSubmitting = ref.watch(accidentesSubmittingProvider);

    final estados = ["Pendiente", "En proceso", "Completado"];

    // ----------------------------------------
    // 3. MAPEO DE NOMBRES
    // ----------------------------------------
    
    // Convertimos los mapas de la BD a listas de Strings para el widget visual
    final listaProyectosNombres = formState.listaProyectos
        .map((e) => (e['Nombre'] ?? e['nombre']).toString())
        .toList();

    final listaContratistasNombres = formState.listaContratistas
        .map((e) => (e['Nombre'] ?? e['nombre']).toString())
        .toList();

    String? nombreProyectoSeleccionado;
    if (formState.proyectoId != null && formState.listaProyectos.isNotEmpty) {
      try {
        final proyecto = formState.listaProyectos.firstWhere(
          (p) => p['id'] == formState.proyectoId,
        );
        nombreProyectoSeleccionado = proyecto['Nombre'] ?? proyecto['nombre'];
      } catch (_) {}
    }

    String? nombreContratistaSeleccionado;
    if (formState.contratistaId != null &&
        formState.listaContratistas.isNotEmpty) {
      try {
        final contratista = formState.listaContratistas.firstWhere(
          (c) => c['id'] == formState.contratistaId,
        );
        nombreContratistaSeleccionado =
            contratista['Nombre'] ?? contratista['nombre'];
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
        double totalCampos = 8.0;
        int llenos = 0;

        // Verificamos campos de texto
        if (eventualidadController.text.isNotEmpty) llenos++;
        if (descripcionController.text.isNotEmpty) llenos++;
        if (diasIncapacidadController.text.isNotEmpty) llenos++;
        if (avancesController.text.isNotEmpty) llenos++;

        // Verificamos campos de seleccion
        if (formState.proyectoId != null) llenos++;
        if (formState.contratistaId != null) llenos++;
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

    // --- INICIALIZACION ---
    useEffect(() {
      if (accidente != null) {
        Future.microtask(() {
          // 1. Seteamos el proyecto (Esto disparara la carga de contratistas)
          formNotifier.setProyectoId(accidente!.proyectoId);

          // 2. Seteamos el resto de campos
          formNotifier.setEstado(accidente!.estado);
          formNotifier.setFecha(accidente!.fechaRegistro);

          // 3. Seteamos el contratista manualmente
          formNotifier.setContratistaId(accidente!.contratistaId);
        });
      }
      return null;
    }, []);

    // ----------------------------------------
    // 6. FUNCION DE ENVIO (SUBMIT)
    //----------------------------------------
    
    /// Funcion para enviar el formulario
    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;

      // Validar campos del estado (Dropdowns y Fecha)
      if (formState.proyectoId == null ||
          formState.contratistaId == null ||
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

      // Crear entidad Accidente
      final nuevoAccidente = Accidente(
        id: accidente?.id,
        eventualidad: eventualidadController.text,
        proyectoId: formState.proyectoId!,
        contratistaId: formState.contratistaId!,
        descripcion: descripcionController.text,
        diasIncapacidad: int.tryParse(diasIncapacidadController.text) ?? 0,
        avances: avancesController.text,
        estado: formState.estado!,
        fechaRegistro: formState.fecha!,
        usuarioId: ref.read(usuarioAutenticadoProvider)?.id ?? 1,
      );

      // Llamar al notifier para crear/actualizar
      final notifier = ref.read(accidenteNotifierProvider.notifier);
      final success = accidente == null
          ? await notifier.crearAccidente(nuevoAccidente)
          : await notifier.actualizarAccidente(nuevoAccidente);

      if (context.mounted) {
        if (success) {
          bool sincronizadoExitosamente = false;

          // 1. Verificar conexión básica
          final hayConexion = await ConnectivityService.tieneInternet();

          if (hayConexion) {
            // Mostrar SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Conexión detectada. Intentando sincronizar...'),
                duration: Duration(seconds: 1),
                backgroundColor: Colors.blue,
              ),
            );

            try {
              // 2. Ejecutar sincronización
              final resultado = await SyncService().sincronizarTodo();

              // 3. VERIFICACIÓN REAL: ¿Se subió algo?
              // Si el total es mayor a 0, significa que la BD se actualizó.
              if (resultado['total']! > 0) {
                sincronizadoExitosamente = true;
              }
            } catch (e) {
              print("Error al sincronizar: $e");
            }
          }

          // Limpiar formulario
          formNotifier.reset();
          eventualidadController.clear();
          descripcionController.clear();
          diasIncapacidadController.clear();
          avancesController.clear();

          // Mostrar diálogo con el mensaje correcto
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
                      Navigator.pop(context); // Cerrar diálogo
                      Navigator.pop(context); // Volver a pantalla anterior
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          // Mostrar error
          final error = ref.read(accidentesErrorProvider);
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
        title: Text(accidente == null ? "Nuevo Accidente" : "Editar Accidente"),
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      /// Titulo del formulario
                      Text(
                        accidente == null ? "Accidente" : "Editar Accidente",
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // --- CAMPOS DEL FORMULARIO ---

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
                        items: listaProyectosNombres,
                        value: nombreProyectoSeleccionado,
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

                      /// Campo: Contratista
                      ListaInputWigets(
                        nameInput: 'Contratista',
                        label: listaContratistasNombres.isEmpty
                            ? 'Selecciona un proyecto primero'
                            : 'Selecciona el contratista',
                        items:
                            listaContratistasNombres, // Solo muestra los validos
                        value:
                            nombreContratistaSeleccionado, // Usamos el del estado, no el controller
                        onChanged: (nombre) {
                          final contratista = formState.listaContratistas
                              .firstWhere(
                                (c) => (c['Nombre'] ?? c['nombre']) == nombre,
                              );
                          formNotifier.setContratistaId(
                            contratista['id'] as int,
                          );
                        },
                        validator: (value) =>
                            value == null ? 'Obligatorio' : null,
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

                      /// Campo: Descripcion
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

                      /// Campo: Dias de incapacidad
                      inputReutilizables(
                        controller: diasIncapacidadController,
                        nameInput: "Días de incapacidad",
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Completa el campo";
                          }
                          if (int.tryParse(value) == null) {
                            return "Debe ser un número";
                          }
                          final numero = int.tryParse(value);
                          if (numero == null || numero <= 0) {
                            return 'Debe ser un número mayor a 0';
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

                      // --- BOTON DE ENVIO ---
                      ElevatedButton(
                        onPressed: isSubmitting ? null : submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 100,
                          ),
                          backgroundColor: CupertinoColors.activeBlue,
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(12),
                          // ),
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
        ],
      ),
    );
  }
}
