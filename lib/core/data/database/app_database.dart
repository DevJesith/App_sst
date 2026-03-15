import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Clase Singleton que gestiona la conexion y estructura de la base de datos SQLite local.
///
/// Contiene el esquema compelo de 19 tablas y datos de prueba (Seeders).
class AppDatabase {
  static final AppDatabase _instancia = AppDatabase._interno();
  factory AppDatabase() => _instancia;
  AppDatabase._interno();

  static Database? _db;

  /// Obtiene la instancia de la base de datos. Si no existe, la inicializa
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    // Nombre de la base de datos
    String path = join(await getDatabasesPath(), 'appsst_final_v1.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // ------------------------------------------------------------------------------
    // 1. TABLAS DEL SISTEMA (Usuarios y recuperar contraseña)
    // ------------------------------------------------------------------------------
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        documento TEXT NOT NULL UNIQUE,
        telefono TEXT NOT NULL,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        email TEXT NOT NULL,
        contrasena TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Codigo_recuperacion (
        id_codigoRecuperacion INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT,
        codigo TEXT,
        fecha_expiracion INTEGER
      )
    ''');

    // ------------------------------------------------------------------------------
    // 2. TABLAS MAESTRAS (Datos que vienen del servidor)
    // ------------------------------------------------------------------------------

    await db.execute(
      'CREATE TABLE Proyecto (id INTEGER PRIMARY KEY, Nombre TEXT, Responsable TEXT, Ubicacion TEXT)',
    );
    await db.execute(
      'CREATE TABLE Contratista (id INTEGER PRIMARY KEY, Nombre TEXT, Ubicacion TEXT, Numero_trabaj INTEGER, Actividad TEXT)',
    );
    await db.execute(
      'CREATE TABLE Trabajador (id INTEGER PRIMARY KEY, Nombres TEXT, Fecha_Nac TEXT, Genero TEXT, Direccion TEXT, Telefono TEXT, Correo TEXT)',
    );
    await db.execute(
      'CREATE TABLE Maquina (id INTEGER PRIMARY KEY, Nombre TEXT, Tipo TEXT, Modelo TEXT, Linea TEXT, Placa TEXT)',
    );
    await db.execute(
      'CREATE TABLE Tipo_Maquina (id INTEGER PRIMARY KEY, Nombre TEXT)',
    );
    await db.execute(
      'CREATE TABLE Tipo_Vehiculo (id INTEGER PRIMARY KEY, descripcion TEXT)',
    );

    // ------------------------------------------------------------------------------
    // 3. TABLAS INTERMEDIAS (Relaciones Muchos a Muchos - La lógica del negocio)
    // ------------------------------------------------------------------------------

    // Relacion: Proyecto <-> Contratista
    await db.execute('''
      CREATE TABLE Contratis_Proyecto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Proyecto_id INTEGER,
        Contratista_id INTEGER,
        Ubicacion TEXT,
        Direccion TEXT,
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id),
        FOREIGN KEY (Contratista_id) REFERENCES Contratista(id)
      )
    ''');

    // Relacion: Contratista <-> Trabajador
    await db.execute('''
      CREATE TABLE Trabajador_Contratis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Proyecto_id INTEGER,
        Contratista_id INTEGER,
        Trabajador_id INTEGER,
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id),
        FOREIGN KEY (Contratista_id) REFERENCES Contratista(id),
        FOREIGN KEY (Trabajador_id) REFERENCES Trabajador(id)
      )
    ''');

    // Relacion: Contratista <-> Maquina
    await db.execute('''
      CREATE TABLE Maquinaria_Contratis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Contratista_id INTEGER,
        Maquina_id INTEGER,
        Proyecto_id INTEGER,
        FOREIGN KEY (Contratista_id) REFERENCES Contratista(id),
        FOREIGN KEY (Maquina_id) REFERENCES Maquina(id),
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id)
      )
    ''');

    // Relacion: Proyecto <-> Maquina
    await db.execute('''
      CREATE TABLE Maquinaria_Proyecto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Contratista_id INTEGER,
        Maquina_id INTEGER,
        Proyecto_id INTEGER,
        Fecha TEXT,
        Departamento TEXT,
        Municipio TEXT,
        Tipo_operacion TEXT,
        Equipo_cargo TEXT,
        Nombre_operador TEXT,
        Cargo_preoperac TEXT,
        Cinturon_seguridad INTEGER,
        Observaciones TEXT,
        Equipo_Operativo TEXT,
        FOREIGN KEY (Contratista_id) REFERENCES Contratista(id),
        FOREIGN KEY (Maquina_id) REFERENCES Maquina(id),
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id)
      )
    ''');

    // Relacion: Proyecto <-> Vehiculos
    await db.execute('''
      CREATE TABLE Vehiculos_Proyecto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Tipo_vehiculo_id INTEGER,
        Descripcion TEXT,
        Placa TEXT,
        Novedad TEXT,
        Contratista_id INTEGER,
        Proyecto_id INTEGER,
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id),
        FOREIGN KEY (Contratista_id) REFERENCES Contratista(id),
        FOREIGN KEY (Tipo_vehiculo_id) REFERENCES Tipo_Vehiculo(id)
      )
    ''');

    // Tabla: Ingreso de Maquinas
    await db.execute('''
      CREATE TABLE Ingreso_Maquinas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Contratista_id INTEGER,
        Maquina_id INTEGER,
        Proyecto_id INTEGER,
        Nombre TEXT,
        Operativo TEXT,
        Preoperacional_Inicial TEXT,
        Preoperacional_Manteni TEXT,
        FOREIGN KEY (Contratista_id) REFERENCES Contratista(id),
        FOREIGN KEY (Maquina_id) REFERENCES Maquina(id),
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id)
      )
    ''');

    // ------------------------------------------------------------------------------
    // 4. TABLAS TRANSACCIONALES (Formularios de recoleccion de datos)
    // ------------------------------------------------------------------------------

    // --- ACCIDENTE ---
    await db.execute('''
      CREATE TABLE Accidente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventualidad TEXT,
        Proyecto_id INTEGER,      
        Contratista_id INTEGER,   
        descripcion TEXT,
        dias_incapacidad INTEGER,
        avances TEXT,
        estado TEXT,
        fecha_registro TEXT,
        fecha_creacion TEXT,
        sincronizado INTEGER DEFAULT 0,
        Usuarios_id INTEGER,
        FOREIGN KEY (Usuarios_id) REFERENCES usuarios(id),
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id),
        FOREIGN KEY (Contratista_id) REFERENCES Contratista(id)
      )
    ''');

    // --- INCIDENTE ---
    await db.execute('''
      CREATE TABLE Incidente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventualidad TEXT,
        Proyecto_id INTEGER,
        descripcion TEXT,
        dias_incapacidad INTEGER,
        avances TEXT,
        estado TEXT,
        fecha_registro TEXT,
        fecha_creacion TEXT,
        sincronizado INTEGER DEFAULT 0,
        Usuarios_id INTEGER,
        FOREIGN KEY (Usuarios_id) REFERENCES usuarios(id),
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id)
      )
    ''');

    // --- ENFERMEDAD LABORAL ---
    await db.execute('''
      CREATE TABLE Enfermedad_Laboral (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventualidad TEXT,
        Proyecto_id INTEGER,
        Contratista_id INTEGER,
        Trabajador_id INTEGER,
        descripcion TEXT,
        dias_incapacidad INTEGER,
        avances TEXT,
        estado TEXT,
        fecha_registro TEXT,
        fecha_creacion TEXT,
        sincronizado INTEGER DEFAULT 0,
        Usuarios_id INTEGER,
        FOREIGN KEY (Usuarios_id) REFERENCES usuarios(id),
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id),
        FOREIGN KEY (Contratista_id) REFERENCES Contratista(id),
        FOREIGN KEY (Trabajador_id) REFERENCES Trabajador(id)
      )
    ''');

    // --- CAPACITACION ---
    await db.execute('''
      CREATE TABLE Capacitacion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Descripcion TEXT,
        Numero_capacita INTEGER,
        Numero_personas INTEGER,
        Responsable TEXT,
        Tema TEXT,
        Proyecto_id INTEGER,     
        Contratista_id INTEGER,   
        fecha_creacion TEXT,      
        sincronizado INTEGER DEFAULT 0,
        Usuarios_id INTEGER,
        FOREIGN KEY (Usuarios_id) REFERENCES usuarios(id),
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id),
        FOREIGN KEY (Contratista_id) REFERENCES Contratista(id)
      )
    ''');

    // --- GESTION INSPECCION ---
    await db.execute('''
      CREATE TABLE Gestion_inspeccion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Proyecto_id INTEGER,
        ee TEXT,
        epp TEXT,
        extintor_maquina TEXT,
        locativa TEXT,
        rutinaria_maquina TEXT,
        gestion_cumpl_cont TEXT,
        foto1 TEXT,
        foto2 TEXT,
        foto3 TEXT,
        fecha_creacion TEXT,
        sincronizado INTEGER DEFAULT 0,
        Usuarios_id INTEGER,
        FOREIGN KEY (Usuarios_id) REFERENCES usuarios(id),
        FOREIGN KEY (Proyecto_id) REFERENCES Proyecto(id)
      )
    ''');

    // --- NOTIFICACIONES ---
    await db.execute('''
      CREATE TABLE Notificaciones(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT,
        cuerpo TEXT,
        fecha TEXT,
        leido INTEGER DEFAULT 0,
        Usuarios_id INTEGER,
        FOREIGN KEY (Usuarios_id) REFERENCES usuarios(id)
      )
    ''');

    // --- PQRS ---
    await db.execute('''
      CREATE TABLE Pqrs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tipo TEXT NOT NULL,
      nombre_solicitante TEXT NOT NULL,
      telefono_contacto TEXT NOT NULL,
      correo_contacto TEXT NOT NULL,
      descripcion TEXT NOT NULL,
      fecha_creacion TEXT NOT NULL,
      estado TEXT DEFAULT 'Pendiente'
      )
    ''');

    // ✅ INSERTAR DATOS DE PRUEBA (SIMULACIÓN)
    await _seedData(db);
  }

  // ------------------------------------------------------------------------------
  // SEEDERS: Datos iniciales para pruebas Offline
  // ------------------------------------------------------------------------------

  Future<void> _seedData(Database db) async {
    print("🌱 Sembrando datos de prueba...");

    // 1. Proyectos
    int p1 = await db.insert('Proyecto', {
      'Nombre': 'Residencial Altos del Norte',
      'Responsable': 'Arq. Carlos',
      'Ubicacion': 'Zona Norte',
    });
    int p2 = await db.insert('Proyecto', {
      'Nombre': 'Puente Centenario',
      'Responsable': 'Ing. Sofia',
      'Ubicacion': 'Vía Principal',
    });

    // 2. Contratistas
    int c1 = await db.insert('Contratista', {
      'Nombre': 'Constructora ABC',
      'Actividad': 'Obra Civil',
    });
    int c2 = await db.insert('Contratista', {
      'Nombre': 'Electricidad Segura SAS',
      'Actividad': 'Redes',
    });
    int c3 = await db.insert('Contratista', {
      'Nombre': 'Maquinaria Pesada LTDA',
      'Actividad': 'Movimiento Tierra',
    });

    // 3. Relacion Proyecto <-> Contratista
    await db.insert('Contratis_Proyecto', {
      'Proyecto_id': p1,
      'Contratista_id': c1,
    });
    await db.insert('Contratis_Proyecto', {
      'Proyecto_id': p1,
      'Contratista_id': c2,
    });

    // En el Proyecto 2 trabaja Maquinaria Pesada
    await db.insert('Contratis_Proyecto', {
      'Proyecto_id': p2,
      'Contratista_id': c3,
    });

    // 4. Trabajadores
    int t1 = await db.insert('Trabajador', {
      'Nombres': 'Pedro Picapiedra',
      'Correo': 'pedro@mail.com',
    });
    int t2 = await db.insert('Trabajador', {
      'Nombres': 'Pablo Marmol',
      'Correo': 'pablo@mail.com',
    });

    // 5. Relacionar Trabajadores
    await db.insert('Trabajador_Contratis', {
      'Proyecto_id': p1,
      'Contratista_id': c1,
      'Trabajador_id': t1,
    });

    print("✅ Datos de prueba insertados correctamente.");
  }

  // ------------------------------------------------------------------------------
  // FUNCIONES DE ACCESO A DATOS (QUERIES)
  // ------------------------------------------------------------------------------

  /// Inserta un nuevo usuario en la base de datos local.
  Future<int> insertarUsuario(
    String documento,
    String telefono,
    String nombre,
    String apellido,
    String email,
    String contrasena,
  ) async {
    final db = await database;
    return await db.insert('usuarios', {
      'documento': documento,
      'telefono': telefono,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'contrasena': contrasena,
    });
  }

  /// Verifica ñas credenciales del usuario para el inicio de sesion.
  /// Retorna el mapa del usuario si existe, o null si no.
  Future<Map<String, dynamic>?> login(String email, String contrasena) async {
    final db = await database;
    final res = await db.query(
      'usuarios',
      where: 'LOWER(email) = ? AND contrasena = ?',
      whereArgs: [email.toLowerCase(), contrasena],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // --- GETTERS PARA LOS DROPDOWNS ---

  /// Obtiene la lista completa de proyectos disponibles.
  Future<List<Map<String, dynamic>>> obtenerProyectos() async {
    final db = await database;
    return await db.query('Proyecto');
  }

  /// Obtiene los contratistas asociados a un proyecto especifico.
  /// Realiza un JOIN con la tabla intermedia 'Contratis_Proyecto'.
  Future<List<Map<String, dynamic>>> obtenerContratistasPorProyecto(
    int proyectoId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT c.id, c.Nombre 
      FROM Contratista c
      INNER JOIN Contratis_Proyecto cp ON c.id = cp.Contratista_id
      WHERE cp.Proyecto_id = ?
    ''',
      [proyectoId],
    );
  }

  /// Obtiene los trabajadores asociados a un contratista en un proyecto especifico
  /// Realiza un JOIN con la tabla intermedia 'Trabajador_Contratis'.
  Future<List<Map<String, dynamic>>> obtenerTrabajadoresPorContratista(
    int proyectoId,
    int contratistaId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT t.id, t.Nombres 
      FROM Trabajador t
      INNER JOIN Trabajador_Contratis tc ON t.id = tc.Trabajador_id
      WHERE tc.Proyecto_id = ? AND tc.Contratista_id = ?
    ''',
      [proyectoId, contratistaId],
    );
  }
}
