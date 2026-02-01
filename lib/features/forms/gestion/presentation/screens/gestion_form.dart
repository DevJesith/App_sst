import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/presentation/providers/gestion_providers.dart';
import 'package:app_sst/services/connectivity_service.dart';
import 'package:app_sst/services/sync_service.dart';
import 'package:app_sst/shared/widgets/inputs_widgets.dart';
import 'package:app_sst/shared/widgets/lista_input_wigets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Pantalla para llenar el formulario de gestión de inspección.
/// Incluye campos de texto y carga de imágenes como evidencia.
class GestionFormScreen extends HookConsumerWidget {
  final Gestion? gestion;

  const GestionFormScreen({Key? key, this.gestion}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // ----------------------------------------
    // 1. CONTROLADORES DE TEXTO
    // ----------------------------------------

    final eeController = useTextEditingController(text: gestion?.ee ?? '');

    final eppController = useTextEditingController(text: gestion?.epp ?? '');
    final locativaController = useTextEditingController(
      text: gestion?.locativa ?? '',
    );
    final extintorMaquinaController = useTextEditingController(
      text: gestion?.extintorMaquina ?? '',
    );
    final rutinariaMaquinaController = useTextEditingController(
      text: gestion?.rutinariaMaquina ?? '',
    );
    final gestionCumpleController = useTextEditingController(
      text: gestion?.gestionCumple ?? '',
    );

    // ----------------------------------------
    // 2. ESTADO Y PROVIDERS
    // ----------------------------------------

    final formState = ref.watch(gestionFormNotifierProvider);
    final formNotifier = ref.read(gestionFormNotifierProvider.notifier);

    final isSubmitting = ref.watch(gestionesSubmittingProvider);

    final imagePicker = useMemoized(() => ImagePicker());

    // ----------------------------------------
    // 3. MAPEO DE NOMBRES
    // ----------------------------------------

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
        if (eeController.text.isNotEmpty) llenos++;
        if (eppController.text.isNotEmpty) llenos++;
        if (extintorMaquinaController.text.isNotEmpty) llenos++;
        if (locativaController.text.isNotEmpty) llenos++;
        if (rutinariaMaquinaController.text.isNotEmpty) llenos++;
        if (gestionCumpleController.text.isNotEmpty) llenos++;
        if (formState.imagenes.isNotEmpty) llenos++;

        // Verificamos campos de seleccion
        if (formState.proyectoId != null) llenos++;

        // Calculamos el procentaje y aseguramos que este entre 0 y 1
        progreso.value = (llenos / totalCampos).clamp(0.0, 1.0);
      });
    }

    // EFECTO 1: Escuchar cambios en los campos de texto
    useEffect(() {
      // Creamos una funcion oyente
      void listener() => calcularProgreso();

      // Le ponemos como tal "oido" a cada controlador
      eeController.addListener(listener);
      eppController.addListener(listener);
      extintorMaquinaController.addListener(listener);
      locativaController.addListener(listener);
      rutinariaMaquinaController.addListener(listener);
      gestionCumpleController.addListener(listener);

      // Limpieza para quitar los listeners al salir para liberar memoria
      return () {
        eeController.removeListener(listener);
        eppController.removeListener(listener);
        extintorMaquinaController.removeListener(listener);
        locativaController.removeListener(listener);
        rutinariaMaquinaController.removeListener(listener);
        gestionCumpleController.removeListener(listener);
      };
    }, [formState]);

    // EFECTO 2: Escucha Dropdowns y Fecha (Riverpod)
    // Este efecto se ejecuta cada vez que 'formState' cambia
    useEffect(() {
      calcularProgreso();
      return null;
    }, [formState]);

    //Funcion para seleccionar foto
    Future<void> pickImage(ImageSource source) async {
      if (formState.imagenes.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximo 3 fotos permitidos')),
        );
        return;
      }

      final XFile? image = await imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        formNotifier.agregarImagen(image);
      }
    }

    //Motrar opciones de camara o galeria
    Future<void> showImageSourceDialog() async {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camara'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }

    // ----------------------------------------
    // 5. LOGICA DE CARGA DE DATOS
    // ---------------------------------------

    useEffect(() {
      if (gestion != null) {
        Future.microtask(() {
          formNotifier.setProyectos(gestion!.proyectoId);
        });
      }
      return null;
    }, []);

    // ----------------------------------------
    // 6. FUNCION DE ENVIO (SUBMIT)
    // ----------------------------------------

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;

      if (formState.proyectoId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecciona un proyecto')));
        return;
      }

      if (formState.imagenes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes subir al menos 1 foto de evidencia'),
          ),
        );
        return;
      }

      // Obtener directorio permanente
      final directory = await getApplicationCacheDirectory();
      final String documentsPath = directory.path;

      Future<String> guardarImagenPermanente(XFile imagen, int index) async {
        //Crear nombre unico: gestion_TIMESTAMP_index.jpg
        final String fileName =
            'gestion_${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
        final String newPath = path.join(documentsPath, fileName);

        // Copiar archivo de cache a documentos
        await File(imagen.path).copy(newPath);
        return newPath;
      }

      // Guardado seguro (Verificar si existen antes de acceder al indice)
      String foto1Path = '';
      String foto2Path = '';
      String foto3Path = '';

      if (formState.imagenes.length > 0) {
        foto1Path = await guardarImagenPermanente(formState.imagenes[0], 1);
      }

      if (formState.imagenes.length > 1) {
        foto2Path = await guardarImagenPermanente(formState.imagenes[1], 2);
      }

      if (formState.imagenes.length > 2) {
        foto3Path = await guardarImagenPermanente(formState.imagenes[2], 3);
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

      final nuevaGestion = Gestion(
        id: gestion?.id,
        ee: eeController.text,
        proyectoId: formState.proyectoId!,
        epp: eppController.text,
        locativa: locativaController.text,
        extintorMaquina: extintorMaquinaController.text,
        rutinariaMaquina: rutinariaMaquinaController.text,
        gestionCumple: gestionCumpleController.text,
        foto1: foto1Path,
        foto2: foto2Path,
        foto3: foto3Path,
        fechaRegistro: DateTime.now(),
        usuarioId: ref.read(usuarioAutenticadoProvider)?.id ?? 1,
      );

      final notifier = ref.read(gestionNotifierProvider.notifier);
      final success = gestion == null
          ? await notifier.crearGestion(nuevaGestion)
          : await notifier.actualizarGestion(nuevaGestion);

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
          eeController.clear();
          eppController.clear();
          locativaController.clear();
          extintorMaquinaController.clear();
          rutinariaMaquinaController.clear();
          gestionCumpleController.clear();
          formNotifier.clearImagenes();

          // Mostrar dialogo de exito
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Éxito'),
                content: Text(
                  sincronizadoExitosamente
                      ? 'Reporte creado y sincronizado con la nube.'
                      : 'Reporte guardado localmente. Se subirá cuando tengas internet',
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
          final error = ref.read(gestionesErrorProvider);
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
        title: Text(gestion == null ? "Nueva Gestion" : "Editar Gestion"),
        leadingWidth: 40,
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
                padding: EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      /// Título del formulario
                      Text(
                        'Gestión de Inspección',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // PROYECTO
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
                          formNotifier.setProyectos(proyecto['id'] as int);
                        },
                        validator: (value) =>
                            value == null ? 'Requerido' : null,
                      ),

                      const SizedBox(height: 20),

                      inputReutilizables(
                        controller: eeController,
                        nameInput: 'EE',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Este campo es obligatorio'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      inputReutilizables(
                        controller: eppController,
                        nameInput: 'EPP',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Este campo es obligatorio'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      inputReutilizables(
                        controller: locativaController,
                        nameInput: 'Locativa',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Este campo es obligatorio'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      inputReutilizables(
                        controller: extintorMaquinaController,
                        nameInput: 'Extintor Maquina',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Este campo es obligatorio'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      inputReutilizables(
                        controller: rutinariaMaquinaController,
                        nameInput: 'Rutinaria Maquina',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Este campo es obligatorio'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      inputReutilizables(
                        controller: gestionCumpleController,
                        nameInput: 'Gestion Cumple',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Este campo es obligatorio'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      /// Sección de imágenes
                      Text(
                        'Foto de evidencia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '${formState.imagenes.length}/3 fotos agregadas',
                        style: TextStyle(
                          color: formState.imagenes.length == 3
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Grid de fotos
                      if (formState.imagenes.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: formState.imagenes.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(formState.imagenes[index].path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      formNotifier.eliminarImagen(index);
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  left: 5,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Foto ${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      const SizedBox(height: 20),

                      // Botón para agregar fotos
                      if (formState.imagenes.length < 3)
                        OutlinedButton.icon(
                          onPressed: showImageSourceDialog,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Agregar Foto'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                          ),
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
