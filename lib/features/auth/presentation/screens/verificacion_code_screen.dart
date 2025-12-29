import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

/// Pantalla de verificacion de codigo de seguridad
/// 
/// Se muestra inmediatamente despues del registro. El usuario debe ingresar
/// el codigo de 6 digitos enviado a su correo electronico para confirmar su identidad
/// antes de que el usuario sea guardado en la BD
class VerificacionCodeScreen extends HookConsumerWidget {

  /// El objeto usuario con los datos capturados en el registro.
  /// Aun no existe en la BD
  final Usuarios usuarioPendiente;

  /// El codigo generado y enviados por email que se debe validar.
  final String codigoGenerado;

  const VerificacionCodeScreen({
    super.key,
    required this.usuarioPendiente,
    required this.codigoGenerado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Controlador para el input del PIN
    final codigoController = useTextEditingController();
    final isLoading = useState(false);

    /// Valida el codigo y finaliza el registro.
    Future<void> verificarYRegistrar() async {
      // 1. Validacion local del codigo
      if (codigoController.text.trim() != codigoGenerado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Código incorrecto"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      isLoading.value = true;

      try {
        // 2. Guardar el usuario en la BD
        // Llamamos el provider que ejecuta el caso de uso 'RegistrarUsuario'
        await ref.read(registrarUsuarioProvider(usuarioPendiente).future);

        if (context.mounted) {
          // 3. Feedback visual
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cuenta verificada y creada con éxito!'),
              backgroundColor: Colors.green,
            ),
          );

          // 4. Navegacion al login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar usuario: $e')),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      appBar: AppBar(
        title: const Text('Verificación'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mark_email_read,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 20),

                    // Instrucciones
                    Text(
                      'Hemos enviado un código a:',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      usuarioPendiente.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    /// Campo de PIN (6 digtos)
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: codigoController,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      // Diseño de las cajitas del PIN
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                        inactiveFillColor: Colors.white,
                        selectedFillColor: Colors.blue.shade50,
                        activeColor: Colors.blue,
                        selectedColor: Colors.blueAccent,
                        inactiveColor: Colors.grey.shade400,
                      ),
                      cursorColor: Colors.black,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      onCompleted: (v) {
                        verificarYRegistrar();
                      },
                      onChanged: (_) {},
                    ),

                    const SizedBox(height: 40),

                    // Boton de verificar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading.value ? null : verificarYRegistrar,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Verificar',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
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
