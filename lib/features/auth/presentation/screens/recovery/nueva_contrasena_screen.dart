import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/utils/crypto_helper.dart';
import '../../../../../../shared/widgets/inputs_widgets.dart';
import '../../../domain/entities/usuarios.dart';
import '../../providers/auth_provider.dart';
import '../login/login_screen.dart';
import 'package:flutter/cupertino.dart';

/// Pantalla para restablecer la contraseña.
///
/// Permite al usuario crear una nueva contraseña despues de verificar
/// su identidad con el codigo de recuperacion.
class NuevaContrasenaScreen extends HookConsumerWidget {
  final Usuarios usuario;

  const NuevaContrasenaScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final passController = useTextEditingController();
    final confirmController = useTextEditingController();
    final isLoading = useState(false);
    final obscurePass = useState(true);
    final obscureConfirm = useState(true);

    /// Actualiza la contraseña en la BD y redirige al login
    Future<void> cambiarContrasena() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        // Crear usuario con la nueva contraseña encriptada
        final usuarioActualizado = Usuarios(
          id: usuario.id,
          nombre: usuario.nombre,
          telefono: usuario.telefono,
          apellido: usuario.apellido,
          email: usuario.email,
          contrasena: CryptoHelper.encriptar(passController.text.trim()),
        );

        // Actualizar en BD
        await ref.read(actualizarUsuarioProvider(usuarioActualizado).future);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );

          // Ir al Login y borrar historial
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
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
        title: const Text('Restablecer Contraseña'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 15),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const Icon(Icons.lock_open, size: 80, color: Colors.orange),
                    const SizedBox(height: 20),
                    const Text(
                      'Crea una nueva contraseña',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Nueva contraseña
                    inputReutilizables(
                      controller: passController,
                      nameInput: 'Nueva Contraseña',
                      obscuredText: obscurePass.value,
                      prefixIcon: const Icon(Icons.lock_outline),

                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (v.length < 6) return 'Minimo 6 caracteres';
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePass.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              obscurePass.value = !obscurePass.value,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CupertinoColors.inactiveGray,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CupertinoColors.activeOrange,
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
                    const SizedBox(height: 20),

                    // Confirmar contraseña
                    inputReutilizables(
                      controller: confirmController,
                      nameInput: 'Confirmar Contraseña',
                      obscuredText: obscureConfirm.value,
                      prefixIcon: const Icon(Icons.lock_outline),

                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Confirma la contraseña';
                        if (v != passController.text)
                          return 'Las contraseñas no coinciden';
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              obscureConfirm.value = !obscureConfirm.value,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CupertinoColors.inactiveGray,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CupertinoColors.activeOrange,
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

                    // Boton
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading.value ? null : cambiarContrasena,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Cambiar Contraseña',
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
          ),
        ),
      ),
    );
  }
}
