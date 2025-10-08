import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';

/// Pantalla que muestra el panel de administración.
/// Lista todos los usuarios registrados en la base de datos local.
/// Usa Riverpod para consumir el proveedor `obtenerTodosUsuariosProvider`.
class AdminDashboard extends HookConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa el estado del proveedor que obtiene todos los usuarios
    final usuariosAsync = ref.watch(obtenerTodosUsuariosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.blue.shade700,
      ),

      /// Muestra contenido según el estado del proveedor
      body: usuariosAsync.when(
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          // Lista de usuarios en tarjetas
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usuarios.length,
            itemBuilder: (_, index) {
              final usuario = usuarios[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    usuario.nombre.isNotEmpty ? usuario.nombre : 'Sin nombre',
                  ),
                  subtitle: Text(usuario.email),
                  trailing: Icon(
                    usuario.verificado ? Icons.verified : Icons.cancel,
                    color: usuario.verificado ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },

        /// Mientras carga los datos
        loading: () => const Center(child: CircularProgressIndicator()),

        /// Si ocurre un error
        error: (e, _) => Center(child: Text('Error al cargar usuarios: $e')),
      ),
    );
  }
}
