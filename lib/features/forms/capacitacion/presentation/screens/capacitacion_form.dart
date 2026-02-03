import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/services/connectivity_service.dart';
import 'package:app_sst/services/sync_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/widgets/inputs_widgets.dart';
import '../../../../../shared/widgets/lista_input_wigets.dart';
import '../../domain/entities/capacitacion.dart';
import '../providers/capacitacion_providers.dart';

/// Pantalla para registrar o editar una Capacitacion
///
/// Maneja la relacion Proyecto -> Contratista mediante listas desplegables.
class CapacitacionFormScreen extends HookConsumerWidget {
  final Capacitacion? capacitacion;

  const CapacitacionFormScreen({Key? key, this.capacitacion}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // ----------------------------------------
    // 1. CONTROLADORES DE TEXTO
    // ----------------------------------------

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
    final temaController = useTextEditingController(
      text: capacitacion?.tema ?? '',
    );

    // ----------------------------------------
    // 2. ESTADO Y PROVIDERS
    // ----------------------------------------

    final formState = ref.watch(capacitacionFormNotifierProvider);
    final formNotifier = ref.read(capacitacionFormNotifierProvider.notifier);
    final isSubmitting = ref.watch(capacitacionesSubmittingProvider);

    // ----------------------------------------
    // 3. MAPEO DE NOMBRES
    // ----------------------------------------

    final nombresProyectos = formState.listaProyectos
        .map((e) => (e['Nombre'] ?? e['nombre']).toString())
        .toList();

    final nombresContratistas = formState.listaContratistas
        .map((e) => (e['Nombre'] ?? e['nombre']).toString())
        .toList();

    String? nombresProyectoSeleccionado;
    if (formState.idProyecto != null && formState.listaProyectos.isNotEmpty) {
      try {
        final proyecto = formState.listaProyectos.firstWhere(
          (p) => p['id'] == formState.idProyecto,
        );
        nombresProyectoSeleccionado = proyecto['Nombre'] ?? proyecto['nombre'];
      } catch (_) {}
    }

    String? nombresContratistaSeleccionado;
    if (formState.idContratista != null &&
        formState.listaContratistas.isNotEmpty) {
      try {
        final contratistas = formState.listaContratistas.firstWhere(
          (c) => c['id'] == formState.idContratista,
        );
        nombresContratistaSeleccionado =
            contratistas['Nombre'] ?? contratistas['nombre'];
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
        if (temaController.text.isNotEmpty) llenos++;
        if (descripcionController.text.isNotEmpty) llenos++;
        if (numeroCapacitaController.text.isNotEmpty) llenos++;
        if (numeroPersonasController.text.isNotEmpty) llenos++;
        if (responsableController.text.isNotEmpty) llenos++;

        // Verificamos campos de seleccion
        if (formState.idProyecto != null) llenos++;
        if (formState.idContratista != null) llenos++;

        // Calculamos el procentaje y aseguramos que este entre 0 y 1
        progreso.value = (llenos / totalCampos).clamp(0.0, 1.0);
      });
    }

    // EFECTO 1: Escuchar cambios en los campos de texto
    useEffect(() {
      // Creamos una funcion oyente
      void listener() => calcularProgreso();

      // Le ponemos como tal "oido" a cada controlador
      temaController.addListener(listener);
      descripcionController.addListener(listener);
      numeroCapacitaController.addListener(listener);
      numeroPersonasController.addListener(listener);
      responsableController.addListener(listener);

      // Limpieza para quitar los listeners al salir para liberar memoria
      return () {
        temaController.removeListener(listener);
        descripcionController.removeListener(listener);
        numeroCapacitaController.removeListener(listener);
        numeroPersonasController.removeListener(listener);
        responsableController.removeListener(listener);
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
      if (capacitacion != null) {
        Future.microtask(() {
          // Carga IDs existentes
          formNotifier.setIdProyecto(capacitacion!.idProyecto);
          formNotifier.setIdContratista(capacitacion!.idContratista);
        });
      }
      return null;
    }, []);

    // ----------------------------------------
    // 6. FUNCION DE ENVIO (SUBMIT)
    // ----------------------------------------

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;

      if (formState.idProyecto == null || formState.idContratista == null) {
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

      final nuevaCapacitacion = Capacitacion(
        id: capacitacion?.id,
        idProyecto: formState.idProyecto!,
        idContratista: formState.idContratista!,
        descripcion: descripcionController.text,
        numeroCapacita: int.tryParse(numeroCapacitaController.text) ?? 0,
        numeroPersonas: int.tryParse(numeroPersonasController.text) ?? 0,
        responsable: responsableController.text,
        tema: temaController.text,
        fechaCreacion: DateTime.now(),
        usuarioId: ref.read(usuarioAutenticadoProvider)?.id ?? 1,
      );

      final notifier = ref.read(capacitacionNotifierProvider.notifier);
      final success = capacitacion == null
          ? await notifier.createCapacitacion(nuevaCapacitacion)
          : await notifier.updateCapacitacion(nuevaCapacitacion);

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

          formNotifier.reset();
          descripcionController.clear();
          numeroCapacitaController.clear();
          numeroPersonasController.clear();
          responsableController.clear();

          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Éxito'),
                content: Text(
                  sincronizadoExitosamente
                      ? 'Reporte creado y sincronizado con la nube.'
                      : 'Reporte guardado localemnte. Se subirá cuando tengas internet.',
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
          final error = ref.read(capacitacionesErrorProvider);
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
          capacitacion == null ? "Nueva Capacitación" : "Editar Capacitación",
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

                        // Proyecto
                        ListaInputWigets(
                          nameInput: 'Proyecto',
                          label: 'Selecciona un proyecto',
                          items: nombresProyectos,
                          value:
                              nombresProyectoSeleccionado, // Le pasamos el nombre, no el ID
                          onChanged: (nombre) {
                            // BUSCAR EL ID BASADO EN EL NOMBRE SELECCIONADO
                            final proyecto = formState.listaProyectos
                                .firstWhere(
                                  (p) => (p['Nombre'] ?? p['nombre']) == nombre,
                                );
                            // Mandar el ID al notifier
                            formNotifier.setIdProyecto(proyecto['id'] as int);
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
                            final contratista = formState.listaContratistas
                                .firstWhere(
                                  (c) => (c['Nombre'] ?? c['nombre']) == nombre,
                                );
                            // Mandar el ID al notifier
                            formNotifier.setIdContratista(
                              contratista['id'] as int,
                            );
                          },
                          validator: (value) =>
                              value == null ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 20),

                        // Campo: Tema
                        inputReutilizables(
                          controller: temaController,
                          nameInput: 'Tema',
                          maxLenght: 50,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es obligatorio';
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
                        const SizedBox(height: 10),

                        // Campo: Número de Capacitación
                        inputReutilizables(
                          controller: numeroCapacitaController,
                          nameInput: 'Número de Capacitación',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es obligatorio';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Debe ser un número';
                            }
                            final numero = int.tryParse(value);
                            if (numero == null || numero <= 0) {
                              return 'Debe ser un número mayor a 0';
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es obligatorio';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Debe ser un número';
                            }
                            final numero = int.tryParse(value);
                            if (numero == null || numero <= 0) {
                              return 'Debe ser un número mayor a 0';
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
