import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Clase utilitaria para el manejo de seleccion de imagenes y permisos.
///
/// Centraliza la logica de:
/// 1. Verificacion y solicitud de permisos (Camara/Galeria).
/// 2. Seleccion de imagenes (Single/Multi).
/// 3. Gestion de listas de imagenes (Eliminar/Limpiar).
class ImageUtils {
  
  // Constructor privado para evitar instanciacion
  ImageUtils._();

  /// Verifica y solicita los permisos necesarios.
  /// 
  /// * source: Puede ser `ImageSource.camera` o `ImageSource.gallery`.
  /// * Retorna `true` si el permiso fue concedido, `false` en caso contrario.
  /// * Muestra un diálogo para ir a configuración si el permiso está bloqueado permanentemente.
  static Future<bool> checkPermission(BuildContext context, ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      // Solicita permiso para usar la camara
      status = await Permission.camera.request();
    } else {
      // Permiso para galeria
      // Permission.photos maneja esto automaticamente en versiones recientes de Android
      status = await Permission.photos.request();

      // Fallback para Android antiguos si photos no aplica
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Si el usuario marco "No volver a preguntar", lo enviamos a configuracion
      if (context.mounted) {
        _showSettingsDialog(context);
      }
      return false;
    } else {
      // Permiso denegado simple
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso denegado. No se puede acceder.'),
            backgroundColor: Colors.orange,
          )
        );
      }
      return false;
    }
  }

  /// Abre la camara o galeria para seleccionar imagenes.
  /// 
  /// * [picker]: Instancia de ImagePicker.
  /// * [currentImages]: Lista actual para validar el maximo permitido.
  /// * [updateImages]: Callback para actualizar el estado con las nuevas imagenes.
  /// * [maxImages]: Limite de imagenes permitidas (Maximo 3 por defecto).
  static Future<void> pickImage({
    required BuildContext context,
    required ImageSource source,
    required ImagePicker picker,
    required List<XFile> currentImages,
    required void Function(List<XFile>) updateImages,
    int maxImages = 3,
  }) async {

    // 1. Verificar permisos antes de abrir el selector
    final hasPermission = await checkPermission(context, source);
    if (!hasPermission) return;

    // 2. Validar limite de imágenes
    if (currentImages.length >= maxImages) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solo puedes subir hasta $maxImages imágenes'),
            backgroundColor: Colors.orange,
          )
        );
      }
      return;
    }

    try {
      if (source == ImageSource.camera) {
        // Camara (una foto a la vez)
        final XFile? picked = await picker.pickImage(
          source: source,
          imageQuality: 80, // Optimizacion de tamaño
        );

        if (picked != null) {
          // Agregamos la nueva foto a la lista existente
          updateImages([...currentImages, picked]);
        }
      } else {
        // Galeria (Multiples fotos)
        final List<XFile> pickedList = await picker.pickMultiImage(
          imageQuality: 80,
        );

        if (pickedList.isNotEmpty) {
          // Calculamos cuantas caben
          final int remainingSlots = maxImages - currentImages.length;

          // Tomamos solo las que caben
          final List<XFile> toAdd = pickedList.take(remainingSlots).toList();

          updateImages([...currentImages, ...toAdd]);

          // Avisar si se descartaron algunas por el limite
          if (pickedList.length > remainingSlots && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Se limitó la selección al máximo permitido')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar la imagen')),
        );
      }
    }
  }

  // --- MeTODOS PRIVADOS ---

  /// Muestra un dialogo explicando por que se necesita el permiso y redirige a configuracion.
  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permiso requerido'),
        content: const Text(
          'El acceso a la cámara/galería está bloqueado permanentemente.\n'
          'Por favor, activa el permiso manualmente en la configuración del sistema.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Abrir configuración'),
          ),
        ],
      )
    );
  }

  /// Elimina una imagen especifica de la lista por su indice.
  static void removeImageAt(
    int index,
    List<XFile> images,
    void Function(List<XFile>) updateImages,
  ) {
    if (index >= 0 && index < images.length) {
      final updated = List<XFile>.from(images)..removeAt(index);
      updateImages(updated);
    }
  }

  /// Limpia todas las imagenes seleccionadas.
  static void clearAllImages(void Function(List<XFile>) updateImages) {
    updateImages([]);
  }
}