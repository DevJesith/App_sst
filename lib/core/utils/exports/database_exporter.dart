import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Clase encargada exclusivamente de la exportacion fisica del archivo de la base de datos
class DatabaseExporter {
  /// Exporta la base de datos SQLite local a una carpeta publica
  /// y abre el menu para compartirla a diferentes apps (WhatsAPP, Drive, Email, etc.).
  ///
  /// Flujo:
  /// 1. Verifica y solicita permisos de almacenamiento (Android).
  /// 2. Localiza el archivo de la base de datos en el sistema
  /// 3. Crea una copia de seguridad en la carpeta de Descargas o Documentos.
  /// 4. Comparte el archivo generado
  static Future<void> exportDatabase(BuildContext context) async {
    try {
      // 1. Gestion de permisos
      if (Platform.isAndroid) {
        // Verifica si tenemos acceso al almacenamiento externo
        if (await Permission.manageExternalStorage.isDenied) {
          // Mostrar dialogo explicativo al usuario antes de pedir el permiso
          if (context.mounted) {
            final shoulRequest = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Permiso necesario'),
                content: const Text(
                  'Para exportar la copia de seguridad, necesitamos acceso al almacenamiento.'
                  'Por favor activa "Permitir acceso para administrar todos los archivos" en la seguiente pantalla.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            );

            if (shoulRequest != true) return;
          }

          //Solicitar el permiso al sistema
          final status = await Permission.manageExternalStorage.request();

          if (!status.isGranted) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permiso denegado. No se puede exportar'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
      }

      // 2. Localizar la base de datos
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'appsst_final_v1.db')); // Nombre de la bd

      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Base de datos no encontrada')),
          );
        }
        return;
      }

      // 3. Definir ruta de destino
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();

        // Si falla, intentar con la carpeta publica de Descargas
        if (directory == null) {
          directory = Directory('/storage/emulated/0/Download');
        }
      } else {
        // iOS
        directory = await getApplicationDocumentsDirectory();
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportPath = '${directory.path}/appsst_backup_$timestamp.db';

      // 4. Copiar el Archivo
      // Asegurar que el directorio exista
      await Directory(directory.path).create(recursive: true);

      // Copiar la BD original a la nueva ruta
      await dbFile.copy(exportPath);

      // 5. Compartir
      if (context.mounted) {
        // Mostrar confirmacion visual
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Base de datos exportada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        //Abrir menu de compartir
        await Share.shareXFiles([
          XFile(exportPath),
        ], text: 'Copia de Seguridad - App SST');
      }
    } catch (e) {
      debugPrint('Error exportando BD: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
