import 'dart:convert';
import 'package:app_sst/services/storage_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../../shared/widgets/inputs_widgets.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard.dart';
import '../recovery/recuperar_contrasena_screen.dart';
import '../user/welcome_screen.dart';

/// Pantalla de inicio de sesion
/// 
/// Permite a los usuarios autenticarse con su correo y contraseña.
/// Tambien maneja el acceso especial para el Administrador
class LoginScreen extends HookConsumerWidget {
  // Credenciales de administrador
  static const String adminEmail = 'admin@sst.com';
  static const String adminPassword = 'admin123';

  const LoginScreen({super.key});

  /// Encripta la contraseña usando SHA256 para compararla con la base de datos
  String encriptar(String texto) {
    final bytes = utf8.encode(texto);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Controladores de textp
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    // Estados locales
    final isLoading = useState(false);
    final obscureText = useState(true);

    // Logica de inicio de sesion
    Future<void> login() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        final email = emailController.text.trim().toLowerCase();
        final contrasena = encriptar(passwordController.text.trim());
        final adminPasswordHash = encriptar(adminPassword);

        // 1. Verificar si es el administrador
        if (email == adminEmail && contrasena == adminPasswordHash) {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          }
          return;
        }

        // 2. Verificar credenciales del usuario normal en la BD
        final usuario = await ref.read(
          loginProvider({
            'email': email,
            'contrasena': contrasena,
          }).future,
        );

        if (context.mounted) {
          if (usuario != null) {


            // Guardar sesion permanentemente
            await StorageService.guardarSesion(usuario.id!);

            // Guardar sesion en el estado global
            ref.read(usuarioAutenticadoProvider.notifier).state = usuario;

            // Redirigir a la pantalla de usuario
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WelcomeScreen(usuario: usuario),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Credenciales incorrectas'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al iniciar sesión: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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

                      /// --- ENCABEZADO ---
                      const Icon(
                        Icons.login,
                        size: 80,
                        color: CupertinoColors.activeBlue,
                      ),
                      const SizedBox(height: 20),

                      /// Título
                      const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      /// Subtítulo
                      const Text(
                        'Ingresa tu correo y contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // --- CAMPOS DE TEXTO

                      /// Email
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
                      const SizedBox(height: 16),

                      /// Contraseña
                      inputReutilizables(
                        controller: passwordController,
                        nameInput: 'Contraseña',
                        obscuredText: obscureText.value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
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
                          suffixIcon: IconButton(
                            onPressed: () =>
                                obscureText.value = !obscureText.value,
                            icon: Icon(
                              obscureText.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// Recuperar contraseña
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecuperarContrasenaScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: CupertinoColors.activeBlue,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- BOTON DE ACCION ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading.value ? null : login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: CupertinoColors.activeBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
                                  'Ingresar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- INFORMACION ADMIN ---
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Admin: admin@sst.com / admin123',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
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