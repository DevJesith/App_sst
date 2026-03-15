import 'dart:convert';
import 'package:app_sst/core/utils/crypto_helper.dart';
import 'package:app_sst/services/email_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../../shared/widgets/inputs_widgets.dart';
import '../../../domain/entities/usuarios.dart';
import '../../providers/auth_provider.dart';
import '../login/login_screen.dart';
import 'verificacion_code_screen.dart';

/// Pantalla de registro de nuevos usuarios
///
/// Maneja el flujo completo dividido en dos pasos
class RegistroScreen extends HookConsumerWidget {
  const RegistroScreen({super.key});

  String encriptar(String texto) {
    final bytes = utf8.encode(texto);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Formularios independientes
    final formKeyStep1 = useMemoized(() => GlobalKey<FormState>());
    final formKeyStep2 = useMemoized(() => GlobalKey<FormState>());

    // Controladores Paso 1
    final documentoController = useTextEditingController();
    final nombreController = useTextEditingController();
    final apellidoController = useTextEditingController();
    final telefonoController = useTextEditingController();

    // Controladores Paso 2
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmController = useTextEditingController();

    // Estados
    final currentStep = useState(0);
    final isLoading = useState(false);
    final obscureText = useState(true);
    final obscureConfirmText = useState(true);

    Future<void> iniciarProcesoRegistro() async {
      if (!formKeyStep2.currentState!.validate()) return;

      //Validar contraseña
      if (passwordController.text.trim() != confirmController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      isLoading.value = true;

      try {
        final email = emailController.text.trim().toLowerCase();

        // 1. Verificar si el email ya existe en la BD local
        final existente = await ref.read(
          obtenerUsuarioPorEmailProvider(email).future,
        );

        if (existente != null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Este correo ya esta registrado"),
                backgroundColor: Colors.orange,
              ),
            );
          }
          isLoading.value = false;
          return;
        }

        // 2. Generar codigo y enviar correo
        final codigo = EmailService.generarCodigo();
        final enviado = await EmailService.enviarCodigoVerificacion(
          email,
          codigo,
        );

        if (!enviado) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No se pudo enviar el correo. Verifica tu conexion.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          isLoading.value = false;
          return;
        }

        // 3. Crear objeto usuario temporal
        final usuarioTemporal = Usuarios(
          documento: documentoController.text.trim(),
          telefono: telefonoController.text.trim(),
          nombre: nombreController.text.trim(),
          apellido: apellidoController.text.trim(),
          email: email,
          contrasena: CryptoHelper.encriptar(passwordController.text.trim()),
        );

        // 4. Navegar a pantalla de verificacion
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerificacionCodeScreen(
                usuarioPendiente: usuarioTemporal,
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

    Widget buildStep1() {
      return Form(
        key: formKeyStep1,
        child: Column(
          children: [
            const Text(
              'Paso 1 de 2: Información Personal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 20),

            // Documento
            inputReutilizables(
              controller: documentoController,
              nameInput: 'Numero de Documento',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Completa el campo';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: '123456789',
                prefixIcon: const Icon(Icons.badge),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.inactiveGray,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre
            inputReutilizables(
              controller: nombreController,
              nameInput: 'Nombre',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Completa el campo';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Ingresa tu nombre(s)',
                prefixIcon: const Icon(Icons.person),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.inactiveGray,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Apellido
            inputReutilizables(
              controller: apellidoController,
              nameInput: 'Apellido',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Completa el campo';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Ingresa tu apellido(s)',
                prefixIcon: const Icon(Icons.badge),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.inactiveGray,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Telefono
            inputReutilizables(
              controller: telefonoController,
              nameInput: 'Telefono',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Completa el campo';
                }
                return null;
              },
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Ingresa tu numero de telefono',
                prefixIcon: const Icon(Icons.phone_outlined),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.inactiveGray,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Botón Siguiente
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (formKeyStep1.currentState!.validate()) {
                    currentStep.value = 1;
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: CupertinoColors.activeBlue,
                ),
                child: const Text(
                  'Siguiente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildStep2() {
      return Form(
        key: formKeyStep2,
        child: Column(
          children: [
            const Text(
              'Paso 2 de 2: Detalles de la Cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 20),

            // Email
            inputReutilizables(
              controller: emailController,
              nameInput: 'Correo electrónico',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Completa el campo';
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
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.inactiveGray,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contraseña
            inputReutilizables(
              controller: passwordController,
              nameInput: 'Contraseña',
              obscuredText: obscureText.value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa una contraseña';
                }
                if (value.length < 6) {
                  return 'Mínimo 6 caracteres';
                }
                return null;
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText.value ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => obscureText.value = !obscureText.value,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.inactiveGray,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                hintText: '******',
              ),
            ),
            const SizedBox(height: 16),

            // Confirmar contraseña
            inputReutilizables(
              controller: confirmController,
              nameInput: 'Confirmar contraseña',
              obscuredText: obscureConfirmText.value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirma tu contraseña';
                }
                if (value != passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmText.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () =>
                      obscureConfirmText.value = !obscureConfirmText.value,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.inactiveGray,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                hintText: '******',
              ),
            ),
            const SizedBox(height: 30),

            // Botones Atrás y Registrar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading.value
                        ? null
                        : () {
                            currentStep.value = 0;
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                        color: CupertinoColors.activeBlue,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Atrás',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : iniciarProcesoRegistro,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: CupertinoColors.activeBlue,
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
                            'Registrar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 55),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 600),
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
            child: Column(
              children: [
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Progreso visual (Barra superior para indicar el paso)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: currentStep.value == 1
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.systemGrey5,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Contenido dinámico con animación suave
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: currentStep.value == 0
                      ? KeyedSubtree(key: const ValueKey(0), child: buildStep1())
                      : KeyedSubtree(key: const ValueKey(1), child: buildStep2()),
                ),

                const SizedBox(height: 24),
                // Login enlace abajo
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
