import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Verifica los permisos necesarios para acceder a la cámara o galería.
/// Muestra diálogos o mensajes si los permisos son denegados o permanentemente bloqueados.
Future<bool> checkPermission(BuildContext context, ImageSource source) async {
  if (source == ImageSource.camera) {
    // Solicita permiso para usar la cámara
    var status = await Permission.camera.request();
    return status.isGranted;
  } else {
    // Solicita permisos para acceder a fotos y almacenamiento
    var photosStatus = await Permission.photos.request();
    var storageStatus = await Permission.storage.request();

    // Si ambos permisos están denegados
    if (!photosStatus.isGranted && !storageStatus.isGranted) {

      // Si alguno está permanentemente denegado, muestra diálogo para abrir configuración
      if (photosStatus.isPermanentlyDenied ||
          storageStatus.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permiso requerido'),
            content: const Text(
              'Activa el permiso en configuración del sistema.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings(); // Abre la configuración del sistema
                },
                child: const Text('Abrir configuración'),
              ),
            ],
          ),
        );
      } else {

        // Si no es permanente, solo muestra un mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de galería denegado')),
        );
      }
      return false;
    }

    return true;
  }
}

/// Abre la cámara o galería para seleccionar imágenes.
/// Controla el número máximo permitido y actualiza la lista de imágenes seleccionadas.
Future<void> pickImage({
  required BuildContext context,
  required ImageSource source,
  required ImagePicker picker,
  required List<XFile> currentImages,
  required void Function(List<XFile>) updateImages,
  int maxImages = 3,
}) async {

  // Verifica permisos antes de continuar
  if (!await checkPermission(context, source)) return;

  final remaining = maxImages - currentImages.length;
  if (remaining <= 0) {

    // Si ya se alcanzó el límite de imágenes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Solo puedes subir hasta $maxImages imágenes')),
    );
    return;
  }

  if (source == ImageSource.camera) {

    // Captura una imagen desde la cámara
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      updateImages([...currentImages, picked]);
    }
  } else {

    // Selecciona múltiples imágenes desde la galería
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {

      // Limita la cantidad de imágenes seleccionadas según el espacio restante
      updateImages([...currentImages, ...picked.take(remaining)]);
    }
  }
}

/// Elimina una imagen específica por índice de la lista actual.
void removeImageAt(
  int index,
  List<XFile> images,
  void Function(List<XFile>) updateImages,
) {
  final updated = List<XFile>.from(images)..removeAt(index);
  updateImages(updated);
}

/// Limpia todas las imágenes seleccionada
void clearAllImages(void Function(List<XFile>) updateImages) {
  updateImages([]);
}
