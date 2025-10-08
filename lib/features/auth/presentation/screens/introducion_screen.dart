import 'package:app_sst/features/auth/presentation/screens/registro_screen.dart';
import 'package:app_sst/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla de bienvenida que introduce al usuario al sistema.
/// Ofrece acceso al registro o inicio de sesión.
class IntroducionScreen extends HookConsumerWidget {
  const IntroducionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),

      /// Usa LayoutBuilder para adaptar el diseño según el tamaño de pantalla
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 600 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_sttt_images.png',
                      width: 300,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 40),

                    /// Título principal
                    const Text(
                      'Seguridad y Salud en el Trabajo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    /// Descripción del propósito del sistema
                    const Text(
                      'Bienvenido a tu espacio digital para reportar, registrar y gestionar riesgos laborales de forma segura y eficiente.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF4A4A4A)),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 50),

                    /// Botón para ir al registro
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => RegistroScreen()),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text(
                          'Ingresar al sistema',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Botón para ir al login si ya tiene cuenta
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                        ),
                        child: const Text(
                          '¿Ya tienes cuenta? Iniciar sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
