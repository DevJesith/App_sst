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
  /// Exporta la base de datos SQLite (Archivo .db)
  static Future<void> exportDatabase(BuildContext context) async {
    try {
      // Solicitar permisos (Android 11+ y anteriores)
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.isDenied) {
          // ... (Lógica de permisos igual que antes) ...
           final status = await Permission.manageExternalStorage.request();
           if (!status.isGranted) return;
        }
      }

      final dbPath = await getDatabasesPath();
      // Asegúrate de usar el nombre correcto de tu BD actual
      final dbFile = File(join(dbPath, 'appsst_final_v1.db')); 

      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Base de datos no encontrada')),
          );
        }
        return;
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory == null) {
          directory = Directory('/storage/emulated/0/Download');
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportPath = '${directory.path}/appsst_backup_$timestamp.db';

      await Directory(directory.path).create(recursive: true);
      await dbFile.copy(exportPath);

      if (context.mounted) {
        Share.shareXFiles([XFile(exportPath)], text: 'Respaldo BD AppSST');
      }
    } catch (e) {
      debugPrint('Error exportando: $e');
    }
  }

  /// Genera un PDF con información detallada y NOMBRES REALES (JOINs)
  static Future<void> generateDatabasePDF(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final pdf = pw.Document();
      final dbPath = await getDatabasesPath();
      // ⚠️ Asegúrate que este nombre coincida con el de tu app_database.dart
      final db = await openDatabase(join(dbPath, 'appsst_final_v1.db')); 

      // 1. USUARIOS
      final usuarios = await db.query('usuarios');

      // 2. ACCIDENTES (Este quedó con texto plano según tu última indicación)
      final accidentes = await db.query('Accidente');

      // 3. INCIDENTES (Relacional: Traemos el nombre del Proyecto)
      final incidentes = await db.rawQuery('''
        SELECT i.*, p.Nombre as nombre_proyecto
        FROM Incidente i
        LEFT JOIN Proyecto p ON i.Proyecto_id = p.id
      ''');

      // 4. GESTIÓN (Relacional: Traemos el nombre del Proyecto)
      final gestiones = await db.rawQuery('''
        SELECT g.*, p.Nombre as nombre_proyecto
        FROM Gestion_inspeccion g
        LEFT JOIN Proyecto p ON g.Proyecto_id = p.id
      ''');

      // 5. CAPACITACIÓN (Relacional: Proyecto y Contratista)
      final capacitaciones = await db.rawQuery('''
        SELECT c.*, p.Nombre as nombre_proyecto, ct.Nombre as nombre_contratista
        FROM Capacitacion c
        LEFT JOIN Proyecto p ON c.Proyecto_id = p.id
        LEFT JOIN Contratista ct ON c.Contratista_id = ct.id
      ''');

      // 6. ENFERMEDAD LABORAL (Relacional Completo: Proyecto, Contratista, Trabajador)
      final enfermedades = await db.rawQuery('''
        SELECT e.*, 
               p.Nombre as nombre_proyecto, 
               c.Nombre as nombre_contratista,
               t.Nombres as nombre_trabajador
        FROM Enfermedad_Laboral e
        LEFT JOIN Proyecto p ON e.Proyecto_id = p.id
        LEFT JOIN Contratista c ON e.Contratista_id = c.id
        LEFT JOIN Trabajador t ON e.Trabajador_id = t.id
      ''');

      await db.close();

      // Construcción del PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              _buildHeader(),
              pw.SizedBox(height: 20),
              
              _buildSectionTitle('Resumen General'),
              _buildSummaryTable([
                ['Usuarios', usuarios.length.toString()],
                ['Accidentes', accidentes.length.toString()],
                ['Incidentes', incidentes.length.toString()],
                ['Gestiones', gestiones.length.toString()],
                ['Capacitaciones', capacitaciones.length.toString()],
                ['Enfermedades', enfermedades.length.toString()],
              ]),
              pw.SizedBox(height: 20),

              if (accidentes.isNotEmpty) ...[
                _buildSectionTitle('Reportes de Accidentes'),
                _buildAccidentesTable(accidentes),
                pw.SizedBox(height: 20),
              ],

              if (incidentes.isNotEmpty) ...[
                _buildSectionTitle('Reportes de Incidentes'),
                _buildIncidentesTable(incidentes),
                pw.SizedBox(height: 20),
              ],

              if (gestiones.isNotEmpty) ...[
                _buildSectionTitle('Gestión de Inspección'),
                _buildGestionesTable(gestiones),
                pw.SizedBox(height: 20),
              ],

              if (capacitaciones.isNotEmpty) ...[
                _buildSectionTitle('Capacitaciones'),
                _buildCapacitacionesTable(capacitaciones),
                pw.SizedBox(height: 20),
              ],

              if (enfermedades.isNotEmpty) ...[
                _buildSectionTitle('Enfermedad Laboral'),
                _buildEnfermedadesTable(enfermedades),
              ],
            ];
          },
        ),
      );

      if (context.mounted) Navigator.pop(context); // Cerrar loading

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => await pdf.save(),
      );

    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- WIDGETS DEL PDF ---

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Reporte Consolidado SST', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text('Generado el: ${DateTime.now().toString().split('.')[0]}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
    );
  }

  static pw.Widget _buildSummaryTable(List<List<String>> data) {
    return pw.Table.fromTextArray(
      headers: ['Módulo', 'Cantidad'],
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }

  // 1. Tabla Accidentes (Texto plano)
  static pw.Widget _buildAccidentesTable(List<Map<String, dynamic>> data) {
    return pw.Table.fromTextArray(
      headers: ['ID', 'Eventualidad', 'Proyecto', 'Contratista', 'Estado'],
      data: data.map((e) => [
        e['id'].toString(),
        e['eventualidad'] ?? '',
        e['proyecto'] ?? '',
        e['contratista'] ?? '',
        e['estado'] ?? '',
      ]).toList(),
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
    );
  }

  // 2. Tabla Incidentes (Con JOIN)
  static pw.Widget _buildIncidentesTable(List<Map<String, dynamic>> data) {
    return pw.Table.fromTextArray(
      headers: ['ID', 'Eventualidad', 'Proyecto', 'Estado'],
      data: data.map((e) => [
        e['id'].toString(),
        e['eventualidad'] ?? '',
        e['nombre_proyecto'] ?? 'ID: ${e['Proyecto_id']}', // Muestra nombre real
        e['estado'] ?? '',
      ]).toList(),
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
    );
  }

  // 3. Tabla Gestión (Con JOIN)
  static pw.Widget _buildGestionesTable(List<Map<String, dynamic>> data) {
    return pw.Table.fromTextArray(
      headers: ['ID', 'Proyecto', 'Cumple', 'Fecha'],
      data: data.map((e) => [
        e['id'].toString(),
        e['nombre_proyecto'] ?? 'ID: ${e['Proyecto_id']}',
        e['gestion_cumpl_cont'] ?? '',
        e['fecha_registro']?.toString().split(' ')[0] ?? '',
      ]).toList(),
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
    );
  }

  // 4. Tabla Capacitaciones (Con JOINs)
  static pw.Widget _buildCapacitacionesTable(List<Map<String, dynamic>> data) {
    return pw.Table.fromTextArray(
      headers: ['ID', 'Tema', 'Proyecto', 'Contratista', 'Asistentes'],
      data: data.map((e) => [
        e['id'].toString(),
        e['Descripcion'] ?? '', // A veces es descripcion o tema
        e['nombre_proyecto'] ?? '',
        e['nombre_contratista'] ?? '',
        e['Numero_personas']?.toString() ?? '0',
      ]).toList(),
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
    );
  }

  // 5. Tabla Enfermedades (Con JOINs Complejos)
  static pw.Widget _buildEnfermedadesTable(List<Map<String, dynamic>> data) {
    return pw.Table.fromTextArray(
      headers: ['ID', 'Eventualidad', 'Proyecto', 'Contratista', 'Trabajador'],
      data: data.map((e) => [
        e['id'].toString(),
        e['eventualidad'] ?? '',
        e['nombre_proyecto'] ?? '',
        e['nombre_contratista'] ?? '',
        e['nombre_trabajador'] ?? '',
      ]).toList(),
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
    );
  }
}