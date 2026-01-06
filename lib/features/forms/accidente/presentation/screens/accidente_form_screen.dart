import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/services/connectivity_service.dart';
import 'package:app_sst/services/sync_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

    // --- CONTROLADORES DE TEXTO ---
    final eventualidadController = useTextEditingController(
      text: accidente?.eventualidad ?? '',
    );
    final contratistaController = useTextEditingController(
      text: accidente?.contratista ?? '',
    );
    final mesController = useTextEditingController(text: accidente?.mes ?? '');
    final descripcionController = useTextEditingController(
      text: accidente?.descripcion ?? '',
    );
    final diasIncapacidadController = useTextEditingController(
      text: accidente?.diasIncapacidad.toString() ?? '',
    );
    final avancesController = useTextEditingController(
      text: accidente?.avances ?? '',
    );

    // --- ESTADO DEL FORMULARIO (RIVERPOD) ---
    final formState = ref.watch(accidenteFormNotifierProvider);
    final formNotifier = ref.read(accidenteFormNotifierProvider.notifier);
    final isSubmitting = ref.watch(accidentesSubmittingProvider);

    // Opciones estaticas
    final estados = ["Pendiente", "En proceso", "Completado"];

    // --- PREPARACION DE LISTAS PARA DROPDOWNS ---
    // Convertimos los mapas de la BD a listas de Strings para el widget visual
    final listaProyectosNombres = formState.listaProyectos
        .map((e) => (e['Nombre'] ?? e['nombre']).toString())
        .toList();

    final listaContratistasNombres = formState.listaContratistas
        .map((e) => (e['Nombre'] ?? e['nombre']).toString())
        .toList();

    // --- INICIALIZACION (EDICION) ---
    useEffect(() {
      if (accidente != null) {
        Future.microtask(() {
          // 1. Seteamos el proyecto (Esto disparara la carga de contratistas)
          formNotifier.setProyecto(accidente!.proyecto);

          // 2. Seteamos el resto de campos
          formNotifier.setEstado(accidente!.estado);
          formNotifier.setFecha(accidente!.fechaRegistro);

          // 3. Seteamos el contratista manualmente
          formNotifier.setContratista(accidente!.contratista);
        });
      }
      return null;
    }, []);

    /// Funcion para enviar el formulario
    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;

      // Validar campos del estado (Dropdowns y Fecha)
      if (formState.proyecto == null ||
          formState.contratista == null ||
          formState.estado == null ||
          formState.fecha == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa todos los campos')),
        );
        return;
      }

      // Crear entidad Accidente
      final nuevoAccidente = Accidente(
        id: accidente?.id,
        eventualidad: eventualidadController.text,
        proyecto: formState.proyecto!,
        contratista: formState.contratista!,
        mes: mesController.text,
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
          contratistaController.clear();
          mesController.clear();
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(accidente == null ? "Nuevo Accidente" : "Editar Accidente"),
        leadingWidth: 50,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                /// Titulo del formulario
                Text(
                  accidente == null ? "Reportar Accidente" : "Editar Accidente",
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

                /// Campo: Contratista
                ListaInputWigets(
                  nameInput: 'Contratista',
                  label: listaContratistasNombres.isEmpty
                      ? 'Selecciona un proyecto primero'
                      : 'Selecciona el contratista',
                  items: listaContratistasNombres, // Solo muestra los validos
                  value: formState
                      .contratista, // Usamos el del estado, no el controller
                  onChanged: formNotifier.setContratista,
                  validator: (value) => value == null ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 20),

                /// Campo: Mes
                inputReutilizables(
                  controller: mesController,
                  nameInput: "Mes",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Completa el campo";
                    }
                    if (int.tryParse(value) == null) {
                      return "Debe ser un número";
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
    );
  }
}
