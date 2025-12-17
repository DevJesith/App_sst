import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class EmailService {
  
  static const String _serviceId = 'service_f6o7yqn';
  static const String _templateId = 'template_ll24ur3';
  static const String _publicKey = 'CZf5kMGFPXOWI16KK';

  static String generarCodigo(){
    var range = Random();
    return (range.nextInt(900000) + 100000).toString();
  }

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