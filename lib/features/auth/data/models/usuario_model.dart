import '../../domain/entities/usuarios.dart';

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

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'],
      nombre: map['nombre'],
      email: map['email'],
      contrasena: map['contrasena'],
      verificado: map['verificado'] == 1,
    );
  }

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
