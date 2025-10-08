import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Clase singleton que gestiona la base de datos local usando SQLite.
/// Contiene lógica para inicializar, crear tablas y ejecutar operaciones CRUD básicas.
class AppDatabase {
  static final AppDatabase _instancia = AppDatabase._interno();
  factory AppDatabase() => _instancia;
  AppDatabase._interno();

  static Database? _db;

  /// Obtiene la instancia de la base de datos, inicializándola si es necesario.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Inicializa la base de datos y define su ubicación.
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'appsst.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// Crea las tablas necesarias al iniciar la base de datos.
  /// Tablas

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

    await db.execute('''
      CREATE TABLE codigos_recuperacion(
      email TEXT PRIMARY KEY,
      codigo TEXT NOT NULL,
      fecha TEXT NOT NULL
      
      )
      ''');
  }

  // FUNCIONES USUARIOS

  /// Inserta un nuevo usuario en la tabla `usuarios`.
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

  /// Verifica si el usuario existe con email y contraseña válidos.
  Future<Map<String, dynamic>?> login(String email, String contrasena) async {
    final db = await database;
    final res = await db.query(
      'usuarios',
      where: 'email = ? AND contrasena = ?',
      whereArgs: [email, contrasena],
    );
    return res.isNotEmpty ? res.first : null;
  }

  /// Marca al usuario como verificado.
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

  /// Verifica si el usuario ya ha sido marcado como verificado.
  Future<bool> estaVerificado(String email) async {
    final db = await database;
    final res = await db.query(
      'usuarios',
      where: 'email = ? AND verificado = 1',
      whereArgs: [email],
    );
    return res.isNotEmpty;
  }

  /// Guarda el código de recuperación para el email dado.
  Future<void> guardarCodigoRecuperacion(String email, String codigo) async {
    final db = await database;

    print('✅ Guardando código: $codigo para $email'); // Para depuración

    await db.insert('codigos_recuperacion', {
      'email': email,
      'codigo': codigo,
      'fecha': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
