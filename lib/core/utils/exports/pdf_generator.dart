import 'package:app_sst/core/data/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Clase encargada de la generacion y diseño del reporte
///
/// Uiliza los paquetes 'pdf' para crear el documento y 'printing' para compartirlo o imprimirlo
///
/// Realiza consultas SQL avanzadas (JOINs) para transformar los IDs numericos
/// almacenados en la BD en nombres legibles para el usuario final.
class PdfGenerator {
  /// Genera un PDF consolidado con la informacion de todos los modulos de la App.
  ///
  /// Flujo del proceso:
  /// 1. Muestra un indicador de carga
  /// 2. Abre la base de datos loca.
  /// 3. Ejecuta las consultas para extrar los datos de las tablas
  /// 4. Construye el docuemnto PDF pagina por pagina.
  /// 5. Guarda el archvio temporalmente y abre el menu de compartir
  static Future<void> generateDatabasePDF(BuildContext context) async {
    try {
      // 1. Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final pdf = pw.Document();

      // 2. Abrir la base de datos
      final db = await AppDatabase().database;

      // -------------------------------------------------
      // 3. EXTRACCION DE DATOS
      // -------------------------------------------------

      // Usuarios: Consulta simple
      final usuarios = await db.query('usuarios');

      // Accidentes: JOIN doble
      final accidentes = await db.rawQuery('''
        SELECT a.*, 
               p.Nombre as nombre_proyecto, 
               c.Nombre as nombre_contratista
        FROM Accidente a
        LEFT JOIN Proyecto p ON a.Proyecto_id = p.id
        LEFT JOIN Contratista c ON a.Contratista_id = c.id 
      ''');

      // Incidentes: Usamos LEFT JOIN para obtener el nombre del Proyecto
      // en lugar de mosrtar solo el ID numero (Proyecto_id).
      final incidentes = await db.rawQuery('''
        SELECT i.*, p.Nombre as nombre_proyecto
        FROM Incidente i
        LEFT JOIN Proyecto p ON i.Proyecto_id = p.id
      ''');

      // Gestion: JOIN con Proyecto
      final gestiones = await db.rawQuery('''
        SELECT g.*, p.Nombre as nombre_proyecto
        FROM Gestion_inspeccion g
        LEFT JOIN Proyecto p ON g.Proyecto_id = p.id
      ''');

      // Capacitacion: JOIN doble (Proyecto y Contratista)
      final capacitaciones = await db.rawQuery('''
        SELECT c.*, p.Nombre as nombre_proyecto, ct.Nombre as nombre_contratista
        FROM Capacitacion c
        LEFT JOIN Proyecto p ON c.Proyecto_id = p.id
        LEFT JOIN Contratista ct ON c.Contratista_id = ct.id
      ''');

      // Enfermedad laboral: JOIN triple (Proyecto, Contratista, Trabajador)
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

      // -------------------------------------------------
      // 4. CONSTRUCCION VISUAL DEL PDF
      // -------------------------------------------------

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              _buildHeader(),
              pw.SizedBox(height: 20),

              // Tabla de resumen
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

              // Secciones detallatadas
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

      // Cerrar indicador de carga
      if (context.mounted) Navigator.pop(context);

      // 5. Guardar y Compartir
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => await pdf.save(),
      );
    } catch (e) {
      // Manejo de errores
      if (context.mounted) {
        // Asegurar que se cierre el loading
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // -------------------------------------------------
  // WIDGETS AUXILIARES (COMPONENTES VISUALES DEL PDF)
  // -------------------------------------------------

  // Construye el encabezado del reporte con titulo y fecha
  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Reporte Consolidado SST',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Generado el: ${DateTime.now().toString().split('.')[0]}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
        ),
        pw.Divider(),
      ],
    );
  }

  /// Construye un titulo de seccion con estilo azul.
  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  /// Construye la tabla de resumen numerico
  static pw.Widget _buildSummaryTable(List<List<String>> data) {
    return pw.Table.fromTextArray(
      headers: ['Módulo', 'Cantidad'],
      data: data,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }

  // TABLAS ESPECIFICAS POR MODULO

  static pw.Widget _buildAccidentesTable(List<Map<String, dynamic>> data) {
    return pw.Table.fromTextArray(
      headers: ['ID', 'Eventualidad', 'Proyecto', 'Contratista', 'Estado'],
      data: data
          .map(
            (e) => [
              e['id'].toString(),
              e['eventualidad'] ?? '',
              e['nombre_proyecto'] ?? '',
              e['nombre_contratista'] ?? '',
              e['estado'] ?? '',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
    );
  }

  // 2. Tabla Incidentes (Con JOIN)
  static pw.Widget _buildIncidentesTable(List<Map<String, dynamic>> data) {
    return pw.Table.fromTextArray(
      headers: ['ID', 'Eventualidad', 'Proyecto', 'Estado'],
      data: data
          .map(
            (e) => [
              e['id'].toString(),
              e['eventualidad'] ?? '',
              e['nombre_proyecto'] ??
                  'ID: ${e['Proyecto_id']}', // Muestra nombre real
              e['estado'] ?? '',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
    );
  }

  // 3. Tabla Gestion (Con JOIN)
  static pw.Widget _buildGestionesTable(List<Map<String, dynamic>> data) {
    return pw.Table.fromTextArray(
      headers: ['ID', 'Proyecto', 'Cumple', 'Fecha'],
      data: data
          .map(
            (e) => [
              e['id'].toString(),
              e['nombre_proyecto'] ?? 'ID: ${e['Proyecto_id']}',
              e['gestion_cumpl_cont'] ?? '',
              e['fecha_registro']?.toString().split(' ')[0] ?? '',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
    );
  }

  // 4. Tabla Capacitaciones (Con JOINs)
  static pw.Widget _buildCapacitacionesTable(List<Map<String, dynamic>> data) {
    return pw.Table.fromTextArray(
      headers: ['ID', 'Tema', 'Proyecto', 'Contratista', 'Asistentes'],
      data: data
          .map(
            (e) => [
              e['id'].toString(),
              e['Descripcion'] ?? '',
              e['nombre_proyecto'] ?? '',
              e['nombre_contratista'] ?? '',
              e['Numero_personas']?.toString() ?? '0',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
    );
  }

  // 5. Tabla Enfermedades (Con JOINs Complejos)
  static pw.Widget _buildEnfermedadesTable(List<Map<String, dynamic>> data) {
    return pw.Table.fromTextArray(
      headers: ['ID', 'Eventualidad', 'Proyecto', 'Contratista', 'Trabajador'],
      data: data
          .map(
            (e) => [
              e['id'].toString(),
              e['eventualidad'] ?? '',
              e['nombre_proyecto'] ?? '',
              e['nombre_contratista'] ?? '',
              e['nombre_trabajador'] ?? '',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
    );
  }
}
