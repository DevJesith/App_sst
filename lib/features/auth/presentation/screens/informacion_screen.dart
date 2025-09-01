import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:app_sst/core/widgets/inputs_widgets.dart';
import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InformacionScreen extends HookConsumerWidget {
  final String email;

  const InformacionScreen({super.key, required this.email});

  String encriptar(String texto) {
    final butes = utf8.encode(texto);
    final hash = sha256.convert(butes);
    return hash.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();

    final nameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxHeight > 600;

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
                      color: Colors.black38,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 60),

                    const SizedBox(height: 20),

                    const Text(
                      'Información personal',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Ingrese tu nombre y contraseña para completar el registro',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          inputReutilizables(
                            controller: nameController,
                            nameInput: 'Nombre(s) y apellido(s)',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Es importante llenar este campo';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Juanito Perez',
                              prefixIcon: const Icon(Icons.person_pin_rounded),
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

                          const SizedBox(height: 15),

                          inputReutilizables(
                            controller: passwordController,
                            nameInput: 'Crear contraseña',
                            keyboardType: TextInputType.visiblePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Es importante llenar este campo';
                              }
                              if (value.length < 6) {
                                return 'Debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '******',
                              prefixIcon: const Icon(Icons.lock),
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

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoading.value
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        isLoading.value = true;

                                        try {
                                          final usuario = Usuarios(
                                            email: email.trim(),
                                            nombre: nameController.text.trim(),
                                            contrasena: encriptar(passwordController.text
                                                .trim()),
                                            verificado: true,
                                          );

                                          final existe = await ref.read(verificarProvider(email).future);

                                          if (existe) {
                                            await ref.read(actualizarUsuarioProvider(usuario).future);
                                          } else {
                                            print("no existe 88888");
                                          }

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => LoginScreen(),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Errror al guardar: ${e.toString()}',
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
                                  : const Icon(Icons.check),
                              label: const Text(
                                'Guardar y continuar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
