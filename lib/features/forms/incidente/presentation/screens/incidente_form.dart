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

class IncidenteFormScreen extends HookConsumerWidget {
  final Incidente? incidente;

  const IncidenteFormScreen({Key? key, this.incidente}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // Estado del formulario
    final formState = ref.watch(incidenteFormNotifierProvider);
    final formNotifier = ref.read(incidenteFormNotifierProvider.notifier);
    final isSubmitting = ref.watch(incidentesSubmittingProvider);

    final estado = ["Pendiente", "En proceso", "Completado"];

    // Mapeo de nombres
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

    // --- INICIALIZACION / LIMPIEZA ---
    useEffect(() {
      Future.microtask(() {
        if (incidente != null) {
          // MODO EDICION: Cargar datos
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

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;

      if (formState.proyectoId == null ||
          formState.estado == null ||
          formState.fecha == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa todos los campos')),
        );
        return;
      }

      final nuevoIncidente = Incidente(
        id: incidente?.id, // Mantiene el ID si es edición
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

          // Limpiar todo
          formNotifier.reset();
          eventualidadController.clear();
          mesController.clear();
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(incidente == null ? "Nuevo Incidente" : "Editar Incidente"),
        leadingWidth: 50,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Text(
                    "Incidente",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  inputReutilizables(
                    controller: eventualidadController,
                    nameInput: "Eventualidad",
                    validator: (v) => v!.isEmpty ? "Requerido" : null,
                  ),
                  const SizedBox(height: 20),
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
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 20),
                  FechaInputWidgets(
                    nameInput: 'Fecha',
                    fecha: formState.fecha,
                    label: 'Selecciona la fecha',
                    onchanged: formNotifier.setFecha,
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 20),
                  inputReutilizables(
                    controller: descripcionController,
                    nameInput: 'Descripcion',
                    maxLenght: 300,
                    validator: (v) => v!.isEmpty ? "Requerido" : null,
                  ),
                  const SizedBox(height: 10),
                  inputReutilizables(
                    controller: diasIncapacidadController,
                    nameInput: 'Dias de capacidad',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Requerido" : null,
                  ),
                  const SizedBox(height: 20),
                  inputReutilizables(
                    controller: avancesController,
                    nameInput: 'Avances',
                    validator: (v) => v!.isEmpty ? "Requerido" : null,
                  ),
                  const SizedBox(height: 20),
                  ListaInputWigets(
                    label: 'Seleccionar un estado',
                    nameInput: 'Estado',
                    items: estado,
                    value: formState.estado,
                    onChanged: formNotifier.setEstado,
                    validator: (v) => v == null ? 'Requerido' : null,
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
    );
  }
}
