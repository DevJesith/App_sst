import 'package:flutter/material.dart';
import '../exports/database_exporter.dart';
import '../exports/pdf_generator.dart';

/// Clase Facade, que centraliza las utilidades de exportacion.
/// 
/// Redirige las llamadas a las clases especificas:
/// DatabaseExporte para el archivo fisico .db
/// PdfGenerator para el reporte visual .pdf
class ExportUtils {

  /// Exporta la base de datos SQLite local.
  static Future<void> exportDatabase(BuildContext context) async {
    return DatabaseExporter.exportDatabase(context);
  }

  /// Genera y comparte el reporte PDF consolidado
  static Future<void> generateDatabasePDF(BuildContext context) async {
    return PdfGenerator.generateDatabasePDF(context);
  }
}