import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/shared/widgets/inputs_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla de edicion d perfil de usuario.
///
/// Diseño responsive
class PerfilScreen extends HookConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el usuario actual del estado global
    final usuarioActual = ref.watch(usuarioAutenticadoProvider);

    // Controladores
    final nombreController = useTextEditingController(
      text: usuarioActual?.nombre ?? '',
    );
    final apellidoController = useTextEditingController(
      text: usuarioActual?.apellido ?? '',
    );
    final emailController = useTextEditingController(
      text: usuarioActual?.email ?? '',
    );

    final isLoading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Funcion para guardar cambios
    Future<void> guardarCambios() async {
      if (!formKey.currentState!.validate()) return;
      if (usuarioActual == null) return;

      isLoading.value = true;

      try {
        //1. Crear usuario actualizado (Mantenemos ID, Email y Contraseña)
        final usuarioEditado = Usuarios(
          id: usuarioActual.id,
          nombre: nombreController.text.trim(),
          apellido: apellidoController.text.trim(),
          email: usuarioActual.email,
          contrasena: usuarioActual.contrasena,
        );

        // 2. Guardar en BD
        await ref.read(actualizarUsuarioProvider(usuarioEditado).future);

        // 3. Actualizar el estado global (Para que el Drawer se actualice solo)
        ref.read(usuarioAutenticadoProvider.notifier).state = usuarioEditado;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Volver al inicio
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
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // --- HEADER ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 30, top: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            usuarioActual?.email ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- FORMULARIO ---
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            // Nombre
                            inputReutilizables(
                              controller: nombreController,
                              nameInput: 'Nombres',
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            const SizedBox(height: 20),

                            // Apellido
                            inputReutilizables(
                              controller: apellidoController,
                              nameInput: 'Apellidos',
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                              prefixIcon: const Icon(Icons.percent_outlined),
                            ),
                            const SizedBox(height: 20),

                            // Email (Solo lectura)
                            Opacity(
                              opacity: 0.7,
                              child: inputReutilizables(
                                controller: emailController,
                                nameInput: 'Correo electronico',
                                readOnly: true,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 8, left: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '* El correo no se puede modificar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Botón Guardar
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading.value
                                    ? null
                                    : guardarCambios,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Guardar Cambios',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
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
