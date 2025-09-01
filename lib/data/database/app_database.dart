import 'package:app_sst/services/recuperacion_contrasena_services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instancia = AppDatabase._interno();
  factory AppDatabase() => _instancia;
  AppDatabase._interno();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'appsst.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Tablas

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      contrasena TEXT NOT NULL,
      verificado INTEGER DEFAULT 0
      )
      ''');

    await db.execute(
      '''
      CREATE TABLE codigos_recuperacion(
      email TEXT PRIMARY KEY,
      codigo TEXT NOT NULL,
      fecha TEXT NOT NULL
      
      )
      '''
    );
  }

  

  // FUNCIONES USUARIOS

  Future<int> insertarUsuario(
    String nombre,
    String email,
    String contrasena,
  ) async {
    final db = await database;
    return await db.insert('usuarios', {
      'nombre': nombre,
      'email': email,
      'contrasena': contrasena,
      'verificado': 0,
    });
  }

  //Verificar si ya existe
  Future<Map<String, dynamic>?> login(String email, String contrasena) async {
    final db = await database;
    final res = await db.query(
      'usuarios',
      where: 'email = ? AND contrasena = ?',
      whereArgs: [email, contrasena],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // Marcar como verificado el usuario

  Future<bool> verificarCodigo(String email) async {
    final db = await database;
    int actualizado = await db.update(
      'usuarios',
      {'verificado': 1},
      where: 'email = ?',
      whereArgs: [email],
    );
    return actualizado > 0;
  }

  //Veriifca si el uusario ya ha sido verificado
  Future<bool> estaVerificado(String email) async {
    final db = await database;
    final res = await db.query(
      'usuarios',
      where: 'email = ? AND verificado = 1',
      whereArgs: [email],
    );
    return res.isNotEmpty;
  }

 // Guardar código de recuperación
Future<void> guardarCodigoRecuperacion(String email, String codigo) async {
  final db = await database;

  print('✅ Guardando código: $codigo para $email'); // Para depuración

  await db.insert(
    'codigos_recuperacion',
    {
      'email': email,
      'codigo': codigo,
      'fecha': DateTime.now().toIso8601String(),
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
  


}
