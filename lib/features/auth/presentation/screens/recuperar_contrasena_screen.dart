import 'dart:math';

import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/auth/presentation/screens/verificar_codigo_screen.dart';
import 'package:app_sst/services/recuperacion_contrasena_services.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Ingresa tu correo registrado'),
            TextField(controller: emailController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final existe = await ref.read(verificarProvider(email).future);
                if (existe) {
                  // Aquí puedes generar y guardar el código

                  final codigo = _generarCodigoRecuperacion();

                  final db = AppDatabase();
                  await db.guardarCodigoRecuperacion(email, codigo);

                  await SendGridServiceRecuperacion.enviarCodigoRecuperacion(
                    email,
                    codigo
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VerificarCodigoScreen(email: email,),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correo no registrado')),
                  );
                }
              },
              child: const Text('Enviar código de verificación'),
            ),
          ],
        ),
      ),
    );
  }
}
