import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Clase utilitaria para el manejo de seguiridad y criptografia
///
/// Se utiliza principalmente para hashear contraseñas antes de
/// almacenarlas en la base de datos local o enviarlas al servidor
class CryptoHelper {
  
  static String encriptar(String texto) {

    // 1. Convertir el texto a una lista de bytes usando codificacion UTF-8
    final bytes = utf8.encode(texto);

    // 2. Aplicar el algoritmo de hashing SHA-256
    final hash = sha256.convert(bytes);

    // 3. Retornar el resultado como una cadena de texto
    return hash.toString();
  }
}