import 'package:app_sst/features/auth/presentation/screens/informacion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/cupertino.dart';

/// Pantalla para ingresar el código de verificación enviado por correo.
/// Si el código es correcto, redirige a la pantalla de información personal.
class IngresarCodigoScreen extends HookConsumerWidget {
  final String emailRecibido; // Email al que se envió el código
  final String codigoCorrecto; // Código que debe coincidir

  const IngresarCodigoScreen({
    super.key,
    required this.emailRecibido,
    required this.codigoCorrecto,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codigoIngresado = useState(
      '',
    ); // Estado para almacenar el código digitado

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Ícono de verificación
                    const Icon(
                      Icons.verified_user,
                      size: 80,
                      color: CupertinoColors.activeBlue,
                    ),
                    const SizedBox(height: 20),

                    /// Título principal
                    const Text(
                      'Verificación de Cuenta',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    /// Texto explicativo y email
                    Text(
                      'Se envió un código a:',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      emailRecibido,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    /// Instrucción para ingresar el código
                    const Text(
                      'Ingresa el código de verificación',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    /// Campo para ingresar el código (PIN)
                    PinCodeTextField(
                      appContext: context,
                      length: 5,
                      keyboardType: TextInputType.number,
                      enableActiveFill: true,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 55,
                        fieldWidth: 55,
                        activeFillColor: Colors.white,
                        selectedFillColor: Colors.white,
                        inactiveFillColor: const Color(0xfff0f2f5),
                        activeColor: const Color(0xff0052cc),
                        selectedColor: const Color(0xff007aff),
                        inactiveColor: const Color(0Xffb0bec5),
                      ),
                      onChanged: (value) {
                        codigoIngresado.value = value;
                      },
                    ),

                    const SizedBox(height: 30),

                    /// Botón para validar el código
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (codigoIngresado.value == codigoCorrecto) {
                            /// Si el código es correcto, redirige a la pantalla de información
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    InformacionScreen(email: emailRecibido),
                              ),
                            );
                          } else {
                            /// Si el código es incorrecto, muestra error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'El cogio ingresado es incorrecto',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'Validar código',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: CupertinoColors.activeBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
