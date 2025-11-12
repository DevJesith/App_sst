// data/database/app_database.dart

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
    return openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // ✅ Tabla simplificada sin campo verificado
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        contrasena TEXT NOT NULL
      )
    ''');
  }

  // ✅ Migración para usuarios existentes
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Eliminar columna verificado si existe
      await db.execute('ALTER TABLE usuarios DROP COLUMN verificado');
      
      // Eliminar tabla de códigos de recuperación
      await db.execute('DROP TABLE IF EXISTS codigos_recuperacion');
    }
  }

  // FUNCIONES CRUD

  Future<int> insertarUsuario(String nombre, String email, String contrasena) async {
    final db = await database;
    return await db.insert('usuarios', {
      'nombre': nombre,
      'email': email,
      'contrasena': contrasena,
    });
  }

  Future<Map<String, dynamic>?> login(String email, String contrasena) async {
    final db = await database;
    final res = await db.query(
      'usuarios',
      where: 'email = ? AND contrasena = ?',
      whereArgs: [email, contrasena],
    );
    return res.isNotEmpty ? res.first : null;
  }
}