import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/services/connectivity_service.dart';
import 'package:app_sst/services/sync_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

    // --- CONTROLADORES DE TEXTO ---
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

    // --- ESTADO DEL FORMULARIO ---
    final formState = ref.watch(capacitacionFormNotifierProvider);
    final formNotifier = ref.read(capacitacionFormNotifierProvider.notifier);
    final isSubmitting = ref.watch(capacitacionesSubmittingProvider);

    // --- PREPARACION DE LISTAS (Map -> String) ---
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

    // --- ENCONTRAR NOMBRES SELECCIONADOS
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

    // --- INICIALIZACION (EDICION)  ---
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
                    formNotifier.setIdProyecto(proyecto['id'] as int);
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
                    final contratista = formState.listaContratistas.firstWhere(
                      (c) => (c['Nombre'] ?? c['nombre']) == nombre,
                    );
                    // Mandar el ID al notifier
                    formNotifier.setIdContratista(contratista['id'] as int);
                  },
                  validator: (value) => value == null ? 'Requerido' : null,
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
