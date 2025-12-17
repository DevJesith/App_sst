import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/auth/presentation/screens/login_screen.dart';
import 'package:app_sst/shared/widgets/inputs_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VerificacionCodeScreen extends HookConsumerWidget {
  final Usuarios usuarioPendiente;
  final String codigoGenerado;

  const VerificacionCodeScreen({
    super.key,
    required this.usuarioPendiente,
    required this.codigoGenerado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codigoController = useTextEditingController();
    final isLoading = useState(false);

    Future<void> verificarYRegistrar() async {
      if (codigoController.text.trim() != codigoGenerado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Codigo incorrecto"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      isLoading.value = true;

      try {
        //El codgio es correcto, procedemos a guardar en la BD

        await ref.read(registrarUsuarioProvider(usuarioPendiente).future);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cuenta verificada y creada con exito!'),
              backgroundColor: Colors.green,
            ),
          );

          // Ir al login y limpiar el stack de navegacion
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar usuario: $e')),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificacion'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Hemos enviado un codigo a: ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              usuarioPendiente.email,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            inputReutilizables(
              controller: codigoController,
              nameInput: "Ingresa el codigo de 6 digitos",
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading.value ? null : verificarYRegistrar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Verificar',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
