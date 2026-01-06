import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/auth/presentation/screens/startup/introducion_screen.dart';
import 'package:app_sst/features/auth/presentation/screens/user/welcome_screen.dart';
import 'package:app_sst/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla invisible que decide a donde nagear al brir la App.
class CheckAuthScreen extends HookConsumerWidget {
  const CheckAuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(() async {
        // 1. Verificar si hay un ID guardado en el celular
        final usuarioId = await StorageService.obtenerSesion();

        if (usuarioId != null) {
          // 2. Si hay un ID, buscamos los datos compeltos en la BD
          // Necesitamos crear un provider para buscar por ID, pero podemos usar el repositorio directo aqui
          // o filtrar la lista. Para ser eficientes, usaremos el repositorio.

          final repo = ref.read(usuarioRepositoryProvider);
          final usuarios = await repo.obtenerTodos();

          try {
            final usuarioEncontrado = usuarios.firstWhere(
              (u) => u.id == usuarioId,
            );

            // 3. Guardar en el estado global y navegar al Home
            ref.read(usuarioAutenticadoProvider.notifier).state =
                usuarioEncontrado;

            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => WelcomeScreen(usuario: usuarioEncontrado),
                ),
              );
            }
          } catch (e) {
            // Si el ID existe en preferencias pero no en la BD (raro), ir al inicio
            _irAlInicio(context);
          }
        } else {
          // 4. Si no hay sesion, ir a la introduccion
          _irAlInicio(context);
        }
      });
      return null;
    }, []);

    // Mientras decide, mostramos un logo o spinner
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  void _irAlInicio(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const IntroducionScreen()),
    );
  }
}
