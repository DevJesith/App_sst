import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Elimina la base de datos local `appsst.db`.
/// Útil para pruebas, reinicios o limpieza de datos.
Future<void> eliminarBD() async{
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'appsst_final_v1.db');

  await deleteDatabase(path);

  print("✅ Base de datos eliminada");
}