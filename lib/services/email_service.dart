import 'dart:convert';
import 'dart:math';
import 'package:app_sst/config.dart';
import 'package:http/http.dart' as http;

/// Servicio encargado del envio de emails transaccionales.
///
/// Utiliza la API de **EmailJS** para enviar codigos de verificacion sin necesidad
/// de un servidor backend propio para el correo.
class EmailService {
  // Credenciales de EmailsJs
  static const String _serviceId = AppConfig.serviceId;
  static const String _templateIdRegistro = AppConfig.templateIdRegistro;
  static const String _templateIdRecuperacion = AppConfig.templateIdRecuperacion;
  static const String _publicKey = AppConfig.publicKey;

  /// Genera un codigo numerico aleatorio de 6 digitos.
  static String generarCodigo() {
    var range = Random();
    return (range.nextInt(900000) + 100000).toString();
  }

  /// Enviar codigo de verificacion al correo del usuario para Registro.
  /// * [destinatario]: El correo electronico del usuario.
  /// * [codigo]: El codigo de 6 digitos generado.
  static Future<bool> enviarCodigoVerificacion(
    String destinatario,
    String codigo,
  ) async {
    return await _enviarEmail(
      destinatario: destinatario,
      codigo: codigo,
      templateId: _templateIdRegistro,
      tipo: 'Verificación de registro',
    );
  }

  /// Enviar codigo de verificacion al correo del usuario para Nueva Contraseña.
  /// * [destinatario]: El correo electronico del usuario.
  /// * [codigo]: El codigo de 6 digitos generado.
  static Future<bool> enviarCodigoRecuperacion(
    String destinatario,
    String codigo,
  ) async {
    return await _enviarEmail(
      destinatario: destinatario,
      codigo: codigo,
      templateId: _templateIdRecuperacion,
      tipo: 'Recuperación de contraseña',
    );
  }

  static Future<bool> _enviarEmail({
    required String destinatario,
    required String codigo,
    required String templateId,
    required String tipo,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': _serviceId,
          'template_id': templateId,
          'user_id': _publicKey,
          'template_params': {'to_email': destinatario, 'code': codigo},
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Correo de $tipo enviado exitosamente a $destinatario");
        return true;
      } else {
        print('❌ Error EmailJS ($tipo): ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error enviando correo de $tipo: $e');
      return false;
    }
  }
}
