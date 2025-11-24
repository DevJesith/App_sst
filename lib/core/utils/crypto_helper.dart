// core/utils/crypto_helper.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoHelper {
  /// Encripta un texto usando SHA256
  static String encriptar(String texto) {
    final bytes = utf8.encode(texto);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}