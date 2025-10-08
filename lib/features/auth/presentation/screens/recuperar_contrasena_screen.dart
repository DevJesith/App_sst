import 'dart:math';

import 'package:app_sst/core/widgets/inputs_widgets.dart';
import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/auth/presentation/screens/verificar_codigo_screen.dart';
import 'package:app_sst/services/recuperacion_contrasena_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app_sst/data/database/app_database.dart';

class RecuperarContrasenaScreen extends HookConsumerWidget {
  const RecuperarContrasenaScreen({super.key});

  String _generarCodigoRecuperacion() {
    final random = Random();
    return (10000 + random.nextInt(90000)).toString(); // Código de 6 dígitos
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = GlobalKey<FormState>();
    final isLoading = useState(false);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                padding: const EdgeInsets.all(15),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: CupertinoColors.activeBlue,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Recuperar contraseña',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Introduce tu correo electrónico con el que te registraste',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    Form(
                      key: formKey,
                      child: inputReutilizables(
                        controller: emailController,
                        nameInput: 'Correo electrónico',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Agrega tu correo';
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
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading.value
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  isLoading.value = true;

                                  final email = emailController.text.trim();
                                  final existe = await ref.read(
                                    verificarProvider(email).future,
                                  );
                                  if (existe) {
                                    // Aquí puedes generar y guardar el código

                                    final codigo = _generarCodigoRecuperacion();

                                    final db = AppDatabase();
                                    await db.guardarCodigoRecuperacion(
                                      email,
                                      codigo,
                                    );

                                    await SendGridServiceRecuperacion.enviarCodigoRecuperacion(
                                      email,
                                      codigo,
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            VerificarCodigoScreen(email: email),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Correo no registrado'),
                                      ),
                                    );
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
                            : const Icon(Icons.send),
                        label: Text(
                          isLoading.value ? 'Enviando...' : 'Enviar código',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
