import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Servicio encargado del envio de emails transaccionales.
/// 
/// Utiliza la API de **EmailJS** para enviar codigos de verificacion sin necesidad
/// de un servidor backend propio para el correo.
class EmailService {
  
  // Credenciales de EmailsJs
  static const String _serviceId = 'service_f6o7yqn';
  static const String _templateId = 'template_ll24ur3';
  static const String _publicKey = 'CZf5kMGFPXOWI16KK';

  /// Genera un codigo numerico aleatorio de 6 digitos.
  static String generarCodigo(){
    var range = Random();
    return (range.nextInt(900000) + 100000).toString();
  }

  /// Envia el codigo de verificacion al correo del usuario.
  /// * [destinatario]: El correo electronico del usuario.
  /// * [codigo]: El codigo de 6 digitos generado
  static Future<bool> enviarCodigoVerificacion(String destinatario, String codigo) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url, 
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': destinatario,
            'code': codigo,
          }
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Correo enviado exitosamente");
        return true;
      } else {
        print('❌ Error EmailJS: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error enviando correo: $e');
      return false;
    }
  }
}