import '../../domain/entities/usuarios.dart';

/// Modelo que extiende la entidad `Usuarios`
/// Permite convertir entre `Map<String, dynamic>` y objeto `UsuarioModel`
/// Ideal para interoperar con SQLite o APIs
class UsuarioModel extends Usuarios {
  UsuarioModel({
    int? id,
    required String nombre,
    required String email,
    required String contrasena,
    bool verificado = false,
  }) : super(
         id: id,
         nombre: nombre,
         email: email,
         contrasena: contrasena,
         verificado: verificado,
       );

  /// Crea una instancia del modelo a partir de un mapa (usado en SQLite)

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'],
      nombre: map['nombre'],
      email: map['email'],
      contrasena: map['contrasena'],
      verificado:
          map['verificado'] == 1, // SQLite guarda booleanos como enteros
    );
  }

  /// Convierte el modelo a un mapa para guardar en SQLite
  Map<String, dynamic> toMap() {
    final map = {
      'nombre': nombre,
      'email': email,
      'contrasena': contrasena,
      'verificado': verificado ? 1 : 0,
    };

    if (id != null) {
      map['id'] = id ?? 0;
    }

    return map;
  }
}
