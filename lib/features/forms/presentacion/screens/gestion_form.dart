import 'package:app_sst/core/widgets/inputs_widgets.dart';
import 'package:app_sst/features/forms/provider/llamados_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_sst/core/utils/image_utils.dart';
import 'dart:io';

class GestionForm extends HookConsumerWidget {
  const GestionForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gestionFormProvider.notifier);
    final state = ref.watch(gestionFormProvider);

    final proyectoController = useTextEditingController();
    final eeController = useTextEditingController();
    final eppController = useTextEditingController();
    final locativaController = useTextEditingController();
    final extintorMaquinaController = useTextEditingController();
    final rutinariaMaquinaController = useTextEditingController();
    final gestionCumpleController = useTextEditingController();

    final picker = ImagePicker();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: Text('Regresar'), leadingWidth: 40),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                Text(
                  'Gestión de Inspección',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

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

                Text(
                  'Foto de evidencia',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => pickImage(
                        context: context,
                        source: ImageSource.camera,
                        picker: picker,
                        currentImages: state.imagenes,
                        updateImages: controller.setImagenes,
                      ),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Tomar foto'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => pickImage(
                        context: context,
                        source: ImageSource.gallery,
                        picker: picker,
                        currentImages: state.imagenes,
                        updateImages: controller.setImagenes,
                      ),
                      icon: Icon(Icons.photo_library),
                      label: Text('Subir fotos'),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                if (state.imagenes.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.imagenes.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(state.imagenes[index].path),
                                width: 150,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  final nuevas = List<XFile>.from(
                                    state.imagenes,
                                  )..removeAt(index);
                                  controller.setImagenes(nuevas);
                                },
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                else
                  Text(
                    'No se ha subido ninguna imagen',
                    style: TextStyle(color: Colors.grey),
                  ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      controller.sendForm(
                        context: context,
                        ref: ref,
                        onSuccess: () {},
                        controllersClear: [
                          proyectoController,
                          eeController,
                          eppController,
                          locativaController,
                          extintorMaquinaController,
                          rutinariaMaquinaController,
                          gestionCumpleController,
                        ],
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 100,
                    ),
                    backgroundColor: CupertinoColors.activeBlue,
                  ),
                  child: Text(
                    'Enviar reporte',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
