// features/auth/data/models/usuario_model.dart

import '../../domain/entities/usuarios.dart';

class UsuarioModel extends Usuarios {
  UsuarioModel({
    int? id,
    required String nombre,
    required String email,
    required String contrasena,
  }) : super(
          id: id,
          nombre: nombre,
          email: email,
          contrasena: contrasena,
        );

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      contrasena: map['contrasena'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'nombre': nombre,
      'email': email,
      'contrasena': contrasena,
    };

    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }
}