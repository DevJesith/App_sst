import 'dart:convert';
import 'package:http/http.dart' as http;

class SendGridService {
  static const _apiKey =
      '';

  static const _fromEmail = 'creedjesith@gmail.com';
  static const _fromName = 'App SST';
  static const _templateId = 'd-13e611e8eab44dd3a5750b769cdee4d3';

  static Future<void> enviarCodigo(String emailDestino, String codigo) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'from': {'email': _fromEmail, 'name': _fromName},
      'personalizations': [
        {
          'to': [
            {'email': emailDestino},
          ],
          'dynamic_template_data': {'codigo': codigo, 'nombre': 'Usuario'},
        },
      ],
      'template_id': _templateId,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 202) {
      print('✅ Correo enviado correctamente a $emailDestino');
    } else {
      print('❌ Error al enviar correo: ${response.statusCode}');
      print('Respuesta: ${response.body}');
    }
  }
}
