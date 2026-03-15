import '../../domain/entities/usuarios.dart';

/// Modelo de datos que representa a un Usuario en la capa de Datos.
/// 
/// Extiende la entidad de dominio [Usuarios] y agrega metodos para la conversion
/// desde/hacia Mapas (Base de datos SQLite).
class UsuarioModel extends Usuarios {
  UsuarioModel({
    int? id,
    required String documento,
    required String telefono,
    required String nombre,
    required String apellido,
    required String email,
    required String contrasena,
  }) : super(
          id: id,
          documento: documento,
          telefono: telefono,
          nombre: nombre,
          apellido: apellido,
          email: email,
          contrasena: contrasena,
        );

  /// Crea una instancia de [UsuarioModel] a partir de un mapa (BD).map
  /// 
  /// Util para convertir los resultados de una consulta SQL (`SELECT`) en objetos Dart.
  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] as int?,
      documento: map['documento'] as String,
      telefono: map['telefono'] as String,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
      email: map['email'] as String,
      contrasena: map['contrasena'] as String,
    );
  }

  /// Convierte la instancia a un mapa para insertar en la BD
  /// 
  /// Util para operaciones `INSERT` o `UPDATE` en SQLite.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'documento': documento,
      'telefono': telefono,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'contrasena': contrasena,
    };

    // Solo incluimos el ID si existe (para actualizaciones)
    // Para inserciones nuevas, SQLite lo autogenera.
    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }
}