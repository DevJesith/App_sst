import 'dart:convert';

import 'package:app_sst/core/widgets/inputs_widgets.dart';
import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/auth/presentation/screens/login_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla para que el usuario cree una nueva contraseña.
/// Se usa después de validar el código de recuperación.
class NuevaContrasenaScreen extends HookConsumerWidget {
  final String email; // Email del usuario que está recuperando su cuenta

  const NuevaContrasenaScreen({super.key, required this.email});

  String encriptar(String texto) {
    final butes = utf8.encode(texto);
    final hash = sha256.convert(butes);
    return hash.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>(); // Llave para validar el formulario

    final passController =
        useTextEditingController(); // Controlador para nueva contraseña

    final confirmController =
        useTextEditingController(); // Controlador para confirmación

    final isLoading = useState(false); // Estado de carga

    final obscureText = useState(true); // Mostrar/ocultar contraseña

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Nueva contraseña')),

      /// Layout adaptable según altura de pantalla
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
                    Icon(
                      Icons.password,
                      size: 80,
                      color: CupertinoColors.activeOrange,
                    ),

                    const SizedBox(height: 20),

                    /// Título
                    const Text(
                      'Nueva contraseña',
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
                      'Ingresa la nueva contraseña con la que quedaras registrado',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    /// Formulario para ingresar y confirmar contraseña
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          /// Campo para nueva contraseña
                          inputReutilizables(
                            controller: passController,
                            nameInput: 'Crear nueva contraseña',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Es imporntante que ingreses la contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
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

                          const SizedBox(height: 15),

                          /// Campo para confirmar contraseña
                          inputReutilizables(
                            controller: confirmController,
                            nameInput: 'Confirmar contraseña',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Es imporntante que confirmes la contraseña';
                              }
                              if (value != passController.text) {
                                return 'Las contraseñas no coinciden';
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

                    const SizedBox(height: 30),

                    /// Botón para guardar la nueva contraseña
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading.value
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  isLoading.value = true;

                                  /// Encripta la nueva contraseña
                                  final nueva = encriptar(
                                    passController.text.trim(),
                                  );

                                  /// Crea el objeto usuario con la nueva contraseña
                                  final usuario = Usuarios(
                                    email: email,
                                    contrasena: nueva,
                                    verificado: true,
                                  );

                                  /// Actualiza el usuario en la base de datos
                                  await ref.read(
                                    actualizarUsuarioProvider(usuario).future,
                                  );

                                  /// Muestra mensaje de éxito
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Contraseña actualizada'),
                                    ),
                                  );

                                  /// Redirige al login
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginScreen(),
                                    ),
                                  );
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
                            : null,
                        label: Text(
                          'Guardar contraseña',
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
