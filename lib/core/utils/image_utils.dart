import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Verifica los permisos para cámara o galería
Future<bool> checkPermission(BuildContext context, ImageSource source) async {
  if (source == ImageSource.camera) {
    var status = await Permission.camera.request();
    return status.isGranted;
  } else {
    var photosStatus = await Permission.photos.request();
    var storageStatus = await Permission.storage.request();

    if (!photosStatus.isGranted && !storageStatus.isGranted) {
      if (photosStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permiso requerido'),
            content: const Text('Activa el permiso en configuración del sistema.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              TextButton(onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              }, child: const Text('Abrir configuración')),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de galería denegado')),
        );
      }
      return false;
    }

    return true;
  }
}

/// Abre la cámara o galería y guarda las imágenes
Future<void> pickImage({
  required BuildContext context,
  required ImageSource source,
  required ImagePicker picker,
  required List<XFile> currentImages,
  required void Function(List<XFile>) updateImages,
  int maxImages = 3,
}) async {
  if (!await checkPermission(context, source)) return;

  final remaining = maxImages - currentImages.length;
  if (remaining <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Solo puedes subir hasta $maxImages imágenes')),
    );
    return;
  }

  if (source == ImageSource.camera) {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      updateImages([...currentImages, picked]);
    }
  } else {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      updateImages([...currentImages, ...picked.take(remaining)]);
    }
  }
}

/// Elimina una imagen por índice
void removeImageAt(int index, List<XFile> images, void Function(List<XFile>) updateImages) {
  final updated = List<XFile>.from(images)..removeAt(index);
  updateImages(updated);
}

/// Limpia todas las imágenes
void clearAllImages(void Function(List<XFile>) updateImages) {
  updateImages([]);
}