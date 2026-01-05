import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../domain/entities/usuarios.dart';
import 'nueva_contrasena_screen.dart';

class VerificarRecuperacionScreen extends HookConsumerWidget {
  final Usuarios usuario;
  final String codigoGenerado;

  const VerificarRecuperacionScreen({
    super.key,
    required this.usuario,
    required this.codigoGenerado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codigoController = useTextEditingController();

    void verificarCodigo() {
      if (codigoController.text.trim() == codigoGenerado) {
        // Código correcto -> Ir a cambiar contraseña
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NuevaContrasenaScreen(usuario: usuario),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código incorrecto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Verificación'),
        backgroundColor: const Color.fromARGB(255, 252, 248, 248),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.security, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                'Ingresa el código',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                'Hemos enviado un código a:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[800], fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                usuario.email,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: codigoController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: const Color.fromARGB(255, 255, 255, 255),
                  inactiveFillColor: const Color.fromARGB(255, 240, 240, 240),
                  selectedFillColor: Colors.orange.shade50,
                  activeColor: Colors.orange,
                  selectedColor: Colors.orange,
                  inactiveColor: Colors.grey.shade400,
                ),
                cursorColor: Colors.black,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                onChanged: (_) {},
                onCompleted: (_) => verificarCodigo(),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: verificarCodigo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Verificar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
