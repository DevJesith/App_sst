import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> eliminarBD() async{
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'appsst.db');

  await deleteDatabase(path);

  print("✅ Base de datos eliminada");
}