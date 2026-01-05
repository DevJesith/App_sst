import 'package:app_sst/services/email_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Imports de Servicios y Utils
import '../../../../../shared/widgets/inputs_widgets.dart';

// Imports de Dominio y Providers
import '../providers/auth_provider.dart';
import 'verificar_recuperacion_screen.dart';

/// Pantalla para el restablecimiento de contraseña (Paso 1).
///
/// 1. Pide el correo.
/// 2. Verifica si existe en la BD local.
/// 3. Envia el código de verificacion.
/// 4. Navega a la pantalla de ingresar código.
class RecuperarContrasenaScreen extends HookConsumerWidget {
  const RecuperarContrasenaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final isLoading = useState(false);

    /// Logica de recuperación
    Future<void> enviarCodigo() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        final email = emailController.text.trim().toLowerCase();

        print('🔍 ========================================');
        print('🔍 Email buscado: "$email"');

        // Invalidar el cache del provider para obtener datos recientes
        ref.invalidate(obtenerUsuarioPorEmailProvider(email));

        // 1. Verificar si el usuario existe en la BD
        final usuario = await ref.read(
          obtenerUsuarioPorEmailProvider(email).future,
        );

        if (usuario == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Este correo no está registrado en el sistema'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          isLoading.value = false;
          return;
        }

        // 2. Generar y enviar codigo
        final codigo = EmailService.generarCodigo();
        final enviado = await EmailService.enviarCodigoRecuperacion(
          email,
          codigo,
        );

        if (!enviado) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Error al enviar el correo. Verifica tu conexión',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          isLoading.value = false;
          return;
        }

        // 3. Ir a la pantalla de verificacion de codigo
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerificarRecuperacionScreen(
                usuario: usuario,
                codigoGenerado: codigo,
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- ENCABEZADO ---
                      const Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 20),

                      /// Titulo
                      const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      /// Subtitulo
                      const Text(
                        'Ingresa tu correo electrónico para recibir un código de verificación',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // --- INPUTS ---

                      /// Campo: Email
                      inputReutilizables(
                        controller: emailController,
                        nameInput: 'Correo electrónico',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: const Icon(Icons.mail_outline),
                          filled: true,
                          fillColor: const Color(0xFFF0F2F5),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- BOTON ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading.value ? null : enviarCodigo,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Enviar Código',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Solo necesitas tu correo registrado para restablecer tu contraseña',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
