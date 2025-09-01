import 'dart:convert';

import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/auth/presentation/screens/login_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NuevaContrasenaScreen extends HookConsumerWidget {
  final String email;
  const NuevaContrasenaScreen({super.key, required this.email});

  String encriptar(String texto) {
    final butes = utf8.encode(texto);
    final hash = sha256.convert(butes);
    return hash.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passController = useTextEditingController();
    final confirmController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Ingresa tu nueva contraseña'),
            TextField(controller: passController, obscureText: true),
            const SizedBox(height: 10),
            TextField(controller: confirmController, obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (passController.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Las contraseñas no coinciden')),
                  );
                  return;
                }

                final nueva = encriptar(passController.text.trim());
                final usuario = Usuarios(email: email, contrasena: nueva, verificado: true);

                await ref.read(actualizarUsuarioProvider(usuario).future);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contraseña actualizada')),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: const Text('Guardar contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}