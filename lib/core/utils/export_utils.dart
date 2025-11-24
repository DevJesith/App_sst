// core/utils/export_utils.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ExportUtils {
  /// Exporta la base de datos SQLite
  static Future<void> exportDatabase(BuildContext context) async {
    try {
      // Solicitar permisos según la versión de Android
      if (Platform.isAndroid) {
        // Para Android 11+ (API 30+)
        if (await Permission.manageExternalStorage.isDenied) {
          // Mostrar diálogo explicativo
          final shouldRequest = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permiso necesario'),
              content: const Text(
                'Para exportar la base de datos, necesitamos acceso al almacenamiento. '
                'En la siguiente pantalla, por favor activa "Permitir acceso para administrar todos los archivos".',
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

          if (shouldRequest != true) return;

          final status = await Permission.manageExternalStorage.request();
          
          if (!status.isGranted) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permiso de almacenamiento denegado'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
      }

      // Obtener la ruta de la base de datos
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'appsst.db'));

      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Base de datos no encontrada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Obtener directorio de descargas o documentos
      Directory? directory;
      if (Platform.isAndroid) {
        // Usar el directorio de documentos de la app (más confiable)
        directory = await getExternalStorageDirectory();
        // Si falla, intentar con Downloads
        if (directory == null) {
          directory = Directory('/storage/emulated/0/Download');
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportPath = '${directory.path}/appsst_backup_$timestamp.db';

      // Crear el directorio si no existe
      await Directory(directory.path).create(recursive: true);

      // Copiar la base de datos
      await dbFile.copy(exportPath);

      if (context.mounted) {
        // Mostrar diálogo con opciones
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Base de datos exportada'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('La base de datos se exportó exitosamente.'),
                const SizedBox(height: 12),
                const Text(
                  'Ruta:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exportPath,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Share.shareXFiles(
                    [XFile(exportPath)],
                    text: 'Base de datos AppSST',
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Compartir'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Genera un PDF con información de la base de datos
  static Future<void> generateDatabasePDF(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final pdf = pw.Document();

      // Obtener datos de la base de datos
      final dbPath = await getDatabasesPath();
      final db = await openDatabase(join(dbPath, 'appsst.db'));

      // Obtener usuarios
      final usuarios = await db.query('usuarios');

      // Obtener accidentes
      final accidentes = await db.query('Accidente');

      // Obtener incidentes
      final incidentes = await db.query('Incidente');

      // Obtener enfermedades
      final enfermedades = await db.query('Enfermedad_Laboral');

      // Obtener gestiones
      final gestiones = await db.query('Gestion_inspeccion');

      await db.close();

      // Crear páginas del PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Título
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Reporte de Base de Datos AppSST',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Fecha de generación
              pw.Text(
                'Fecha de generación: ${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
              pw.SizedBox(height: 30),

              // Resumen
              pw.Header(level: 1, text: 'Resumen'),
              pw.SizedBox(height: 10),
              _buildSummaryTable([
                ['Usuarios registrados', usuarios.length.toString()],
                ['Accidentes reportados', accidentes.length.toString()],
                ['Incidentes reportados', incidentes.length.toString()],
                ['Enfermedades reportadas', enfermedades.length.toString()],
                ['Gestiones registradas', gestiones.length.toString()],
              ]),
              pw.SizedBox(height: 30),

              // Usuarios
              pw.Header(level: 1, text: 'Usuarios Registrados'),
              pw.SizedBox(height: 10),
              if (usuarios.isNotEmpty)
                _buildUsuariosTable(usuarios)
              else
                pw.Text('No hay usuarios registrados'),
              pw.SizedBox(height: 30),

              // Accidentes
              pw.Header(level: 1, text: 'Accidentes Reportados'),
              pw.SizedBox(height: 10),
              if (accidentes.isNotEmpty)
                _buildAccidentesTable(accidentes)
              else
                pw.Text('No hay accidentes reportados'),
              pw.SizedBox(height: 30),

              // Incidentes
              pw.Header(level: 1, text: 'Incidentes Reportados'),
              pw.SizedBox(height: 10),
              if (incidentes.isNotEmpty)
                _buildIncidentesTable(incidentes)
              else
                pw.Text('No hay incidentes reportados'),
            ];
          },
        ),
      );

      // Cerrar indicador de carga
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Obtener directorio de almacenamiento
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final pdfPath = '${directory.path}/appsst_reporte_$timestamp.pdf';

      // Guardar el PDF
      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        // Mostrar opciones
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ PDF generado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('El PDF se guardó en:'),
                const SizedBox(height: 8),
                Text(
                  pdfPath,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Printing.sharePdf(
                    bytes: await file.readAsBytes(),
                    filename: 'appsst_reporte.pdf',
                  );
                },
                child: const Text('Compartir'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async =>
                        await file.readAsBytes(),
                  );
                },
                child: const Text('Ver PDF'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Cerrar indicador si está abierto
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Construir tabla de resumen
  static pw.Widget _buildSummaryTable(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: data.map((row) {
        return pw.TableRow(
          children: row.map((cell) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                cell,
                style: pw.TextStyle(
                  fontWeight: row == data.first
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  // Construir tabla de usuarios
  static pw.Widget _buildUsuariosTable(List<Map<String, dynamic>> usuarios) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('ID', isHeader: true),
            _buildTableCell('Nombre', isHeader: true),
            _buildTableCell('Email', isHeader: true),
          ],
        ),
        // Datos
        ...usuarios.map((usuario) {
          return pw.TableRow(
            children: [
              _buildTableCell(usuario['id'].toString()),
              _buildTableCell(usuario['nombre']),
              _buildTableCell(usuario['email']),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Construir tabla de accidentes
  static pw.Widget _buildAccidentesTable(
      List<Map<String, dynamic>> accidentes) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('ID', isHeader: true),
            _buildTableCell('Eventualidad', isHeader: true),
            _buildTableCell('Proyecto', isHeader: true),
            _buildTableCell('Estado', isHeader: true),
            _buildTableCell('Usuario', isHeader: true),
          ],
        ),
        // Datos
        ...accidentes.map((accidente) {
          return pw.TableRow(
            children: [
              _buildTableCell(accidente['id'].toString()),
              _buildTableCell(accidente['eventualidad']),
              _buildTableCell(accidente['proyecto']),
              _buildTableCell(accidente['estado']),
              _buildTableCell(accidente['Usuarios_id'].toString()),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Construir tabla de incidentes
  static pw.Widget _buildIncidentesTable(
      List<Map<String, dynamic>> incidentes) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('ID', isHeader: true),
            _buildTableCell('Eventualidad', isHeader: true),
            _buildTableCell('Proyecto', isHeader: true),
            _buildTableCell('Estado', isHeader: true),
          ],
        ),
        // Datos
        ...incidentes.map((incidente) {
          return pw.TableRow(
            children: [
              _buildTableCell(incidente['id'].toString()),
              _buildTableCell(incidente['eventualidad']),
              _buildTableCell(incidente['proyecto']),
              _buildTableCell(incidente['estado']),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Helper para crear celdas de tabla
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}