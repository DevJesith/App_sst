import 'dart:convert';
import 'package:crypto/crypto.dart'; // Para encriptar la contraseña

import 'package:app_sst/core/widgets/inputs_widgets.dart';
import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/auth/presentation/screens/admin_dashboard.dart';
import 'package:app_sst/features/auth/presentation/screens/recuperar_contrasena_screen.dart';
import 'package:app_sst/features/auth/presentation/screens/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla de inicio de sesión para acceder a la plataforma.
/// Valida credenciales y redirige según el tipo de usuario.
class LoginScreen extends HookConsumerWidget {
  // Credenciales de administrador
  final String adminEmail = 'admin@sst.com';
  final String adminPassword = 'admin123';

  const LoginScreen({super.key});

  /// Encripta la contraseña usando SHA256
  String encriptar(String texto) {
    final bytes = utf8.encode(texto);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>(); // Llave para validar el formulario

    final emailController = useTextEditingController(); // Controlador de email

    final passwordController =
        useTextEditingController(); // Controlador de contraseña

    final isLoading = useState(false); // Estado de carga

    final obscureText = useState(true); // Mostrar/ocultar contraseña

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxHeight > 600;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                padding: EdgeInsets.all(15),
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Ícono principal
                    Icon(
                      Icons.vpn_key_sharp,
                      size: 80,
                      color: CupertinoColors.activeOrange,
                    ),

                    const SizedBox(height: 20),

                    /// Título
                    const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    /// Subtítulo
                    const Text(
                      'Ingresa tu correo electrónico y contraseña para ingresar a la plataforma',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    /// Formulario de login
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          /// Campo de correo electrónico
                          inputReutilizables(
                            controller: emailController,
                            nameInput: 'Correo electronico',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Es importante que agregue su correo';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Introduce un correo válido';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'ejemplo@correo.com',
                              prefixIcon: Icon(Icons.mail_outline),
                              filled: true,
                              fillColor: Color(0XFFF0F2F5),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// Campo de contraseña
                          inputReutilizables(
                            controller: passwordController,
                            nameInput: 'Contraseña',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Es imporntante que ingreses la contraseña';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '******',
                              prefixIcon: Icon(Icons.password),
                              filled: true,
                              fillColor: const Color(0xFFF0F2F5),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    obscureText.value = !obscureText.value,
                                icon: Icon(
                                  obscureText.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                            obscuredText: obscureText.value,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Enlace para recuperar contraseña
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecuperarContrasenaScreen(),
                          ),
                        );
                      },
                      child: Text('¿Olvidaste contraseña?'),
                    ),

                    const SizedBox(height: 30),

                    /// Botón para iniciar sesión
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading.value
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  isLoading.value = true;

                                  try {
                                    final email = emailController.text.trim();
                                    final contrasena = encriptar(
                                      passwordController.text.trim(),
                                    );
                                    final adminPasswordHash = encriptar(
                                      adminPassword,
                                    );

                                    /// Verifica credenciales del usuario
                                    final usuario = await ref.read(
                                      loginProvider({
                                        'email': email,
                                        'contrasena': contrasena,
                                      }).future,
                                    );

                                    /// Verifica si es el administrador
                                    if (email == adminEmail &&
                                        contrasena == adminPasswordHash) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdminDashboard(),
                                        ),
                                      );
                                      return;
                                    }

                                    /// Si el usuario existe y está verificado

                                    if (usuario != null && usuario.verificado) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              WelcomeScreen(usuario: usuario),
                                        ),
                                      );
                                    } else {
                                      /// Si no existe o no está verificado
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            usuario == null
                                                ? 'Credenciales incorrectas'
                                                : 'Tu cuenta aun no esta verificado',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    /// Error inesperado
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error al iniciar sesion: ${e.toString()}',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    isLoading.value = false;
                                  }
                                }
                              },
                        icon: isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.arrow_forward),
                        label: Text(
                          'Ingresar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: CupertinoColors.activeBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
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
