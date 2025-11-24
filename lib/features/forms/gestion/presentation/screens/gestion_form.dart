import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/forms/gestion/domain/entities/gestion.dart';
import 'package:app_sst/features/forms/gestion/presentation/providers/gestion_providers.dart';
import 'package:app_sst/shared/widgets/inputs_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Pantalla para llenar el formulario de gestión de inspección.
/// Incluye campos de texto y carga de imágenes como evidencia.
class GestionFormScreen extends HookConsumerWidget {
  final Gestion? gestion;

  const GestionFormScreen({Key? key, this.gestion}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    //Controllers
    final eeController = useTextEditingController(text: gestion?.ee ?? '');
    final proyectoController = useTextEditingController(text: gestion?.proyecto ?? '');
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

    final formState = ref.watch(gestionFormNotifierProvider);
    final formNotifier = ref.read(gestionFormNotifierProvider.notifier);

    final isSubmitting = ref.watch(gestionesSubmittingProvider);

    final imagePicker = useMemoized(() => ImagePicker());

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

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;

      if (formState.imagenes.length < 3) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Debes subir 3 fotos')));
        return;
      }
      //Convertir XFILE paths a String
      final foto1Path = formState.imagenes[0].path;
      final foto2Path = formState.imagenes[1].path;
      final foto3Path = formState.imagenes[2].path;

      final nuevaGestion = Gestion(
        id: gestion?.id,
        ee: eeController.text,
        proyecto: proyectoController.text,
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
          formNotifier.reset();
          eeController.clear();
          eppController.clear();
          locativaController.clear();
          extintorMaquinaController.clear();
          rutinariaMaquinaController.clear();
          gestionCumpleController.clear();

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Formulario enviado'),
              content: const Text('Completado con exito'),
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
        } else {
          final error = ref.read(gestionesErrorProvider);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error ?? 'Error desconocido')));
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(gestion == null ? "Nueva Gestion" : "Editar Gestion"),
        leadingWidth: 40,
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
                  'Gestión de Inspección',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // /// Campos de texto
                inputReutilizables(
                  controller: proyectoController,
                  nameInput: 'Proyecto',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Este campo es obligatorio'
                      : null,
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
                  nameInput: 'Epp',
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                formNotifier.eliminarImagen(index);
                              },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
